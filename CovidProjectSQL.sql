USE Portfolio_project1;

-- CHECKING OUT THE TABLES

SELECT TOP 5 *
FROM [covid-deaths];

SELECT TOP 5 *
FROM [covid-vaccinations];

-- Selecting the data that we will use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [covid-deaths]
ORDER BY 1,2;

-- Looking at total cases v/s total deaths

SELECT location, date, total_cases,  total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS percent_death
FROM [covid-deaths]
ORDER BY 1,2;

SELECT location, date, total_cases,  total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS percent_death
FROM [covid-deaths]
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at total cases v/s population

SELECT location, date, population, total_cases, CAST(total_cases AS float)/CAST(population AS float)*100 AS percent_infected
FROM [covid-deaths]
ORDER BY 1,2;

SELECT location, date, population, total_cases, CAST(total_cases AS float)/CAST(population AS float)*100 AS percent_infected
FROM [covid-deaths]
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at countries with highest infection rate (compared to population)

SELECT location, population, MAX(CAST(total_cases AS int)) AS infect_count, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS percent_infected
FROM [covid-deaths]
GROUP BY location, population
ORDER BY percent_infected DESC;

SELECT location, population, MAX(CAST(total_cases AS int)) AS infect_count, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS percent_infected
FROM [covid-deaths]
WHERE location = 'India'
GROUP BY location, population
ORDER BY percent_infected;

-- Showing countries with highest death count per population

SELECT location, population, MAX(CAST(total_deaths AS int)) AS death_count, MAX(CAST(total_deaths AS float)/CAST(population AS float)) AS death_percent
FROM [covid-deaths]
GROUP BY location, population
ORDER BY death_percent DESC;


SELECT location, population, MAX(CAST(total_deaths AS int)) AS death_count, MAX(CAST(total_deaths AS float)/CAST(population AS float)) AS death_percent
FROM [covid-deaths]
WHERE location = 'India'
GROUP BY location, population
ORDER BY death_percent DESC;


-- Breaking things down by continent 


SELECT location, population, MAX(CAST(total_deaths AS int)) AS death_count, MAX(CAST(total_deaths AS float)/CAST(population AS float)) AS death_percent
FROM [covid-deaths]
WHERE continent IS NULL
GROUP BY location, population
ORDER BY death_percent DESC;

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM [covid-deaths]
WHERE continent IS NOT NULL 
GROUP BY date
HAVING SUM(CAST(new_deaths AS int)) <> 0
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM [covid-deaths]
WHERE continent IS NOT NULL  
HAVING SUM(CAST(new_deaths AS int)) <> 0
ORDER BY 1,2;

-- Looking at total population v/s vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population , CAST(vac.new_vaccinations AS int) AS new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_new_vaccinations
FROM [covid-deaths] AS dea
JOIN [covid-vaccinations] AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
ORDER BY 1;

-- Creating a CTE

WITH CTE AS(
SELECT dea.continent, dea.location, dea.date, dea.population , CAST(vac.new_vaccinations AS int) AS new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_new_vaccinations
FROM [covid-deaths] AS dea
JOIN [covid-vaccinations] AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
)
SELECT *, rolling_sum_new_vaccinations/population AS vaccination_population_ratio
FROM CTE
ORDER BY location, date;

-- CTE with the full syntax

WITH CTE(continent, location, date, population, new_vaccinations, rolling_sum_new_vaccinations)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population , CAST(vac.new_vaccinations AS int) AS new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_new_vaccinations
FROM [covid-deaths] AS dea
JOIN [covid-vaccinations] AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
)
SELECT *, rolling_sum_new_vaccinations/population AS vaccination_population_ratio
FROM CTE
ORDER BY location, date;

-- Creating temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_sum_new_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population , CAST(vac.new_vaccinations AS int) AS new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_new_vaccinations
FROM [covid-deaths] AS dea
JOIN [covid-vaccinations] AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL;

SELECT * 
FROM #PercentPopulationVaccinated
ORDER BY 2,3;

-- Creating View for later data visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population , CAST(vac.new_vaccinations AS int) AS new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_new_vaccinations
FROM [covid-deaths] AS dea
JOIN [covid-vaccinations] AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL

SELECT * FROM PercentPopulationVaccinated







