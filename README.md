# COVID-19 Data Exploration (SQL Portfolio Project)

This repository contains a guided SQL exploration of a COVID‑19 dataset following the **“Data Analyst Bootcamp for Beginners”** course by *Alex The Analyst*. The goal of the project is to practice core SQL skills (SELECTs, filtering, aggregations, joins, window functions, CTEs, temp tables, and views) while producing analysis-ready outputs that can be used later in Tableau/Power BI.

---

## Project Structure

- `sql/01_covid_deaths_exploration.sql`  
  Exploratory queries focused on **cases, deaths, infection rate, and global/continent rollups**.

- `sql/02_covid_vaccinations_exploration.sql`  
  Exploration combining **deaths + vaccinations** using **JOINs**, **window functions**, **CTEs**, **temp tables**, and a reusable **VIEW**.

- `data/`  
   source files here if you want to version them (often avoided if files are large).

---

## Dataset

Two tables are used (imported from Excel/CSV into SQL Server):

- `dbo.CovidDeaths`  
  Contains daily country-level totals such as cases, deaths, population, and continent.

- `dbo.CovidVaccinations`  
  Contains daily country-level vaccination metrics such as `new_vaccinations`.

> Tip: In many public COVID datasets, some numeric fields can be imported as text. The scripts handle this using `CAST`/`TRY_CAST`.

---

## Tools & Skills Practiced

**SQL (T‑SQL / SQL Server)**

- Fundamentals: `SELECT`, `WHERE`, `ORDER BY`
- Aggregations: `GROUP BY`, `MAX`, `SUM`
- Data quality: safe division with `NULLIF`, type conversions with `CAST` / `TRY_CAST`
- Joins: `INNER JOIN` on `(location, date)`
- Window functions: `SUM(...) OVER (PARTITION BY ... ORDER BY ...)`
- CTEs: `WITH ... AS (...)`
- Temp tables: `#TempTable`
- Views: `CREATE OR ALTER VIEW`

**Workflow**

- Importing Excel data into SQL Server
- Building repeatable, well-commented SQL scripts
- Preparing outputs for visualization tools (Tableau / Power BI)

---

## How to Run

1. Create a database (example used in scripts: `PortfolioProject`).
2. Import the datasets into:
   - `dbo.CovidDeaths`
   - `dbo.CovidVaccinations`
3. Run the scripts in order:

```sql
-- run in SQL Server Management Studio
sql/01_covid_deaths_exploration.sql
sql/02_covid_vaccinations_exploration.sql
```

---

## Query Walkthrough (What each section does)

### `01_covid_deaths_exploration.sql`



1. **Core columns**
   - Selects the most-used fields (location/date/cases/deaths/population) for readable outputs.

2. **Total Cases vs Total Deaths (Case Fatality Rate)**
   - Calculates `% deaths among reported cases` for a given country filter.

3. **Total Cases vs Population (Infection Rate)**
   - Calculates `% of population infected (reported)` over time.

4. **Countries with highest infection rate (peak)**
   - Finds each country’s maximum infection percentage during the whole period.

5. **Countries with highest death count**
   - Compares countries by maximum total deaths.

6. **Countries with highest death rate**
   - Normalizes deaths by population for better comparison.

7. **Continents with highest death count**
   - Aggregates deaths at continent level.

8. **Global numbers**
   - Global daily totals and global overall totals.

### `02_covid_vaccinations_exploration.sql`

1. **Join deaths + vaccinations**
   - Creates a combined dataset on `(location, date)`.

2. **Rolling vaccinations**
   - Uses a window function to compute cumulative vaccinations.

3. **CTE: Percent of population vaccinated**
   - Calculates cumulative vaccinations as a percentage of population.

4. **Temp table**
   - Stores the rolling vaccination dataset for reuse (e.g., export to BI).

5. **View**
   - Creates `dbo.vw_PopulationVsVaccinations` so BI tools can query a stable dataset directly.

---

## What I Learned (Course Milestones)

This project consolidates the SQL topics from the bootcamp timeline:

- Writing clean, readable queries and sorting results
- Filtering with `WHERE` and working with real-world messy imports
- Aggregating metrics with `GROUP BY` and comparing across regions
- Combining tables with `JOIN`s (and why join keys matter)
- Building rolling totals with window functions
- Structuring more advanced logic with **CTEs**
- Using **temp tables** for intermediate datasets
- Creating a **view** to support dashboards and repeatable analysis

---

## Next Steps

- Build a Tableau / Power BI dashboard using `dbo.vw_PopulationVsVaccinations`
- Add more metrics (7-day moving averages, vaccination rate changes, etc.)
- Create stored procedures for parameterized country/continent analysis

---

## Credits

- Bootcamp video: **Data Analyst Bootcamp for Beginners** — Alex The Analyst  
- COVID dataset source: public COVID reporting datasets (commonly based on Our World in Data)
