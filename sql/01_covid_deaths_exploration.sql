/*
  COVID-19 Data Exploration (Deaths / Cases)
  Author: <your-name>
  Platform: Microsoft SQL Server (T-SQL)
  Database: PortfolioProject
  Tables:
    - dbo.CovidDeaths

  
*/


/* 
    Columns used for exploration (keep the dataset narrow)
   Utility: focus on the fields used in most analyses and
   keep results easy to read and export.
    */
SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM dbo.CovidDeaths
ORDER BY location, date;


/* 
    Total Cases vs Total Deaths (Case Fatality Rate)
   Utility: estimate % of reported cases that resulted in death.
   Notes: Use NULLIF to avoid divide-by-zero.
    */
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0)) * 100.0 AS case_fatality_rate_pct
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'      -- change filter (e.g., '%Tunisia%')
ORDER BY location, date;


/* 
    Total Cases vs Population (Infection Rate)
   Utility: estimate % of population reported as infected.
    */
SELECT
    location,
    date,
    population,
    total_cases,
    (CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0)) * 100.0 AS infection_rate_pct
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL         -- exclude aggregates like 'World', 'High income', etc.
ORDER BY location, date;


/* 
    Countries with Highest Infection Rate (Peak)
   Utility: identify the maximum infection_rate_pct per country.
    */
SELECT
    location,
    population,
    MAX(total_cases) AS max_total_cases,
    MAX((CAST(total_cases AS float) / NULLIF(CAST(population AS float), 0)) * 100.0) AS max_infection_rate_pct
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_infection_rate_pct DESC;


/* 
    Countries with Highest Death Count
   Utility: compare absolute death burden by country.
   Notes: total_deaths may be stored as text in some imports,
   so cast safely.
    */
SELECT
    location,
    MAX(CAST(total_deaths AS int)) AS max_total_deaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_total_deaths DESC;


/* 
    Countries with Highest Death Rate per Population
   Utility: normalize death burden by population.
    */
SELECT
    location,
    population,
    MAX(CAST(total_deaths AS int)) AS max_total_deaths,
    MAX((CAST(CAST(total_deaths AS int) AS float) / NULLIF(CAST(population AS float), 0)) * 100.0) AS max_death_rate_pct
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_death_rate_pct DESC;


/* 
    Continents with Highest Death Count
   Utility: roll up to continent level.
   Notes: Some rows may use continent=NULL for aggregates like
   'World'. Filtering continent IS NOT NULL keeps true continents.
    */
SELECT
    continent,
    MAX(CAST(total_deaths AS int)) AS max_total_deaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_total_deaths DESC;


/* 
    Global Numbers by Date
   Utility: trend global totals over time.
   Notes: new_deaths may be text; cast safely.
    */
SELECT
    date,
    SUM(CAST(new_cases AS float)) AS global_new_cases,
    SUM(CAST(new_deaths AS float)) AS global_new_deaths,
    (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100.0 AS global_case_fatality_rate_pct
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


/* 
    Global Totals (Entire Period)
   Utility: single-row snapshot across all dates.
    */
SELECT
    SUM(CAST(new_cases AS float))  AS global_cases,
    SUM(CAST(new_deaths AS float)) AS global_deaths,
    (SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0)) * 100.0 AS global_case_fatality_rate_pct
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL;

