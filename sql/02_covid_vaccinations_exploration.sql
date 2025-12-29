/*
  COVID-19 Data Exploration (Deaths + Vaccinations)
  Author: Kerkeni Amir
  Platform: Microsoft SQL Server (T-SQL)
  Database: PortfolioProject
  Tables:
    - dbo.CovidDeaths
    - dbo.CovidVaccinations

  Goal:
  - Combine deaths/cases with vaccination data.
  - Practice joins, window functions, CTEs, temp tables, and views.
*/


/* 
    Join Deaths + Vaccinations on (location, date)
   Utility: create a unified dataset for analysis.
    */
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    d.total_cases,
    d.total_deaths,
    v.new_vaccinations
FROM dbo.CovidDeaths AS d
INNER JOIN dbo.CovidVaccinations AS v
    ON d.location = v.location
   AND d.date  = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;


/* 
   Rolling Vaccinations (Window Function)
   Utility: compute cumulative vaccinations per location.
   Notes: new_vaccinations may be NULL or text depending on import.
    */
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    TRY_CAST(v.new_vaccinations AS float) AS new_vaccinations,
    SUM(TRY_CAST(v.new_vaccinations AS float)) OVER (
        PARTITION BY d.location
        ORDER BY d.location, d.date
        --ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_vaccinations
FROM dbo.CovidDeaths AS d
INNER JOIN dbo.CovidVaccinations AS v
    ON d.location = v.location
   AND d.date   = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;


/* 
    CTE: Percent of Population Vaccinated (Cumulative)
   Utility: calculate vaccination progress as % of population.
    */
WITH PopVsVac AS (
    SELECT
        d.continent,
        d.location,
        d.date,
        d.population,
        TRY_CAST(v.new_vaccinations AS float) AS new_vaccinations,
        SUM(TRY_CAST(v.new_vaccinations AS float)) OVER (
            PARTITION BY d.location
            ORDER BY d.location, d.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_vaccinations
    FROM dbo.CovidDeaths AS d
    INNER JOIN dbo.CovidVaccinations AS v
        ON d.location = v.location
       AND d.date   = v.date
    WHERE d.continent IS NOT NULL
)
SELECT
    *,
    (cumulative_vaccinations / NULLIF(CAST(population AS float), 0)) * 100.0 AS pct_population_vaccinated
FROM PopVsVac
ORDER BY location, date;


/* 
    Temp Table: Reusable vaccination progress dataset
   Utility: store intermediate results for downstream queries
   (e.g., Tableau/Power BI extracts, additional aggregations).
    */
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    continent                  nvarchar(255),
    location                   nvarchar(255),
    date                      date,
    population                 float,
    new_vaccinations           float,
    cumulative_vaccinations    float
);

INSERT INTO #PercentPopulationVaccinated (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
SELECT
    d.continent,
    d.location,
    d.date,
    CAST(d.population AS float) AS population,
    TRY_CAST(v.new_vaccinations AS float) AS new_vaccinations,
    SUM(TRY_CAST(v.new_vaccinations AS float)) OVER (
        PARTITION BY d.location
        ORDER BY d.location, d.date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_vaccinations
FROM dbo.CovidDeaths AS d
INNER JOIN dbo.CovidVaccinations AS v
    ON d.location = v.location
   AND d.date   = v.date
WHERE d.continent IS NOT NULL;

SELECT
    *,
    (cumulative_vaccinations / NULLIF(population, 0)) * 100.0 AS pct_population_vaccinated
FROM #PercentPopulationVaccinated
ORDER BY location, date;
GO

/* 
   View: Persisted dataset for BI tools
   Utility: create a stable object that visualization tools can
   query without re-running the whole script.
    */
CREATE OR ALTER VIEW dbo.vw_PopulationVsVaccinations AS
SELECT
    d.continent,
    d.location,
    d.date,
    CAST(d.population AS float) AS population,
    TRY_CAST(v.new_vaccinations AS float) AS new_vaccinations,
    SUM(TRY_CAST(v.new_vaccinations AS float)) OVER (
        PARTITION BY d.location
        ORDER BY d.location, d.date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_vaccinations
FROM dbo.CovidDeaths AS d
INNER JOIN dbo.CovidVaccinations AS v
    ON d.location = v.location
   AND d.date   = v.date
WHERE d.continent IS NOT NULL;
GO

-- Example query against the view:
SELECT *
FROM dbo.vw_PopulationVsVaccinations
ORDER BY location, date;

