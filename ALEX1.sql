-- SELECT *
-- FROM PortfolioProject.dbo.CovidDeaths
-- WHERE continent IS NOT NULL
-- ORDER BY location, date;

-- -- Death rate shows likelihood of death in the US if you contract COVID
-- SELECT location, date, total_cases, total_deaths, ROUND(CAST(total_deaths AS float) / total_cases * 100, 1) AS death_rate
-- FROM CovidDeaths
-- WHERE location LIKE '%States%' AND continent IS NOT NULL
-- ORDER BY location, date;

-- -- Infection rate shows percentage of a country's population that has contracted COVID
-- SELECT location, population, MAX(total_cases) AS max_total_cases, MAX(ROUND(CAST(total_cases AS float) / population * 100, 1)) AS infection_rate
-- FROM CovidDeaths
-- WHERE continent IS NOT NULL
-- GROUP BY location, population
-- ORDER BY infection_rate DESC;

-- -- Countries with Highest Death Rates
-- SELECT location, MAX(total_deaths) AS max_total_deaths
-- FROM CovidDeaths
-- WHERE continent IS NOT NULL
-- GROUP BY location
-- ORDER BY max_total_deaths DESC;

-- -- Continents with Highest Death Rates
-- SELECT continent, MAX(total_deaths) AS max_total_deaths
-- FROM CovidDeaths
-- WHERE continent IS NOT NULL
-- GROUP BY continent
-- -- HAVING location IN ('North America', 'South America', 'Europe', 'Africa', 'Asia', 'Oceania')
-- ORDER BY max_total_deaths DESC;

-- -- Global Numbers
-- SELECT SUM(new_cases) AS global_new_cases, SUM(new_deaths) AS global_new_deaths, ROUND(SUM(CAST(new_deaths AS float))/SUM(new_cases)*100, 2) AS global_death_percentage
-- FROM CovidDeaths
-- WHERE continent IS NOT NULL;


-- Total Population vs Vaccinations
-- CTE
-- WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
-- AS (
-- SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) 
--   OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_total_vaccinations
--   FROM CovidDeaths AS cd
--   JOIN CovidVaccinations AS cv
--     ON cd.location = cv.location
--    AND cd.date = cv.date
--  WHERE cd.continent IS NOT NULL AND cv.new_vaccinations IS NOT NULL
-- )
-- SELECT *, ROUND(CAST(rolling_total_vaccinations AS float)/population*100, 2) AS vaccinated_percentage
-- FROM pop_vs_vac
-- ORDER BY location, date;


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime, 
  Population numeric,
  New_vaccinations numeric,
  Rolling_total_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) 
  OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_total_vaccinations
  FROM CovidDeaths AS cd
  JOIN CovidVaccinations AS cv
    ON cd.location = cv.location
   AND cd.date = cv.date
 WHERE cd.continent IS NOT NULL AND cv.new_vaccinations IS NOT NULL

SELECT *, ROUND(CAST(rolling_total_vaccinations AS float)/population*100, 2) AS vaccinated_percentage
FROM #PercentPopulationVaccinated
ORDER BY location, date;