-- COVID DATA EXPLORATION USING SQL IN MS SQL Server --
USE PortfolioProject;

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4


select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3, 4


--SELECT DATA TO USE

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


--TOTAL CASES VS TOTAL DEATHS

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%desh%'
order by 1, 2


--FIND WHAT PERCENTAGE OF POPULATION INFECTED BY COVID

select location, date, population, total_cases,(total_cases/population)*100 AS PopulationPercentage
from PortfolioProject..CovidDeaths
--where location like '%desh%'
order by 1, 2


--COUNTRUIES WITH HIGHEST INFECTION RATE

select location, population, MAX(total_cases)AS Highest_infection_count, 
MAX(total_cases/population)*100 AS Population_Percentage_Infection
from PortfolioProject..CovidDeaths
where continent is not null
--and location like '%desh%'
group by location, population
order by Population_Percentage_Infection desc


--COUNTRIES WITH MAXIMUM DEATH COUNT PER POPULATION

select location, MAX(CAST(total_deaths AS INT)) AS Total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
--and location like '%desh%'
group by location
order by Total_death_count desc


--BREAKING DOWN DATA BY CONTINENT

select continent, MAX(CAST(total_deaths AS INT)) AS Total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_death_count desc


--GLOBAL NUMBERS

select date, SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS INT)) AS total_death, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2



--WORLDWIDE TOTAL CASES & DEATHS

select SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS INT)) AS total_death, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


--JOINING TWO TABLES (DEATHS & VACCINATIONS)

select *
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date


--TOTAL POPULATION VS VACCINATION

select d.continent, d.location, d.date, d.population, v.new_vaccinations
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2, 3



--PERCENTAGE OF POPULATION THAT HAS RECEIVED AT LEAST ONE COVID VACCINE

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
order by 2,3




-- USING CTE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY

 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPeoplePerPopulation
From PopvsVac




-- USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPerPopulation
From #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null

