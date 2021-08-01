  
-- Link to visualisation on Tableau: 
-- https://public.tableau.com/app/profile/sufiyan.n.yo/viz/DynamicCOVID-19Dashboard/COVID9Dashboard


--Sufiyan QUIRIES FOR VISUALIZATION IN TABLEAU PUBLIC

--(1)-- Global numbers

SELECT SUM(CONVERT(int,new_cases)) AS Cummulative_Confirmed_Cases, SUM(CONVERT(int,new_deaths)) AS Cummulative_Deaths, 
       (SUM(CONVERT(int,new_deaths))/SUM(new_Cases))*100 AS Percentage_Dead
	   --If you divide two integers you will get an integer, in order to aviod getting only zero we need to set one to float.
FROM PortfolioProject1..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1,2

--(2)- Percentage of the population confirmed positve

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  
       Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--(3)- Countries with Highest Death Count per Population

SELECT Location, MAX(CONVERT(int,total_deaths)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--(4)- Percentage of the population confirmed positve with date

SELECT Location,Population,Date, MAX(total_cases) AS HighestInfectionCount,  
       Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY Location,Population, Date
ORDER BY PercentPopulationInfected DESC


--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

--	QUERIES TO EXPLORE AND PREPARE DATA 

SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
ORDER BY 3,4

--Select Data that we need for the project 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

-- Total Cases vs. Total Deaths
-- Likelihood of dying if you get Covid depending on your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location = 'United kingdom'
ORDER BY 1,2

-- Total Cases vs. Population
-- What percentage of the population contracted Covid19

SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 AS CovidCasePercentage
FROM PortfolioProject1..CovidDeaths
WHERE location = 'United kingdom'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  
       Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location = 'United Kingdom'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Continents with Highest Infection Rate compared to Population

SELECT continent, MAX(total_cases) AS HighestInfectionCount,  
       Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(CONVERT(int,total_deaths)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE 'Ghana'
WHERE continent IS NULL and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Same results as the above Query
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CONVERT(int,total_deaths)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(CONVERT(int,new_cases)) AS Cummulative_Confirmed_Cases, SUM(CONVERT(int,new_deaths)) AS Cummulative_Deaths, 
       (SUM(CONVERT(int,new_deaths))/SUM(new_Cases))*100 AS Percentage_Dead
	   --If you divide two integers you will get an integer, in order to aviod getting only zero we need to set one to float.
FROM PortfolioProject1..CovidDeaths 
WHERE continent is not null 
ORDER BY 1,2

-- Global Population vs. Vaccinations
-- Percentage of Population that has recieved one or more Covid Vaccine

SELECT death.continent, death.date,death.location, death.population, vacc.new_vaccinations
       , SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	   AS RollingPeopleVaccinated
-- Almost like GROUP BY but will yeild more more rows than GROUP BY, its like a group by inside a group by.
/*, (RollingPeopleVaccinated/population)*100   -->
we can not create an alias as a column and reuse it in aggregation or a new column, hence we need to use a CTE or Temporary Table*/
FROM PortfolioProject1..CovidDeaths death
JOIN PortfolioProject1..CovidVaccinations vacc
	 ON death.location = vacc.location
	 AND death.date = vacc.date
WHERE death.continent is not null 
ORDER BY 2,3


--A CTE (Common Table Expression) is a temporary result set that you can reference within another SELECT statement
-- We can use CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.date,death.location, death.population, vacc.new_vaccinations
       , SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	   AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths death
JOIN PortfolioProject1..CovidVaccinations vacc
	 ON death.location = vacc.location
	 AND death.date = vacc.date
WHERE death.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePeopleVaccinated
FROM PopvsVac


--The views are for connecting directly to Tableau or Power BI for visualisation.

-- Creating View to store data for later visualizations percentage of population vaccinated
DROP VIEW IF EXISTS PercentPopulationVaccinated
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.date,death.location, death.population, vacc.new_vaccinations
       , SUM(CONVERT(int,vacc.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) 
	   AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths death
JOIN PortfolioProject1..CovidVaccinations vacc
	 ON death.location = vacc.location
	 AND death.date = vacc.date
WHERE death.continent IS NOT NULL
