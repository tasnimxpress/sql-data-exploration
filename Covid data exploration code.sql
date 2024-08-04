-- 1. Total cases in Bangladesh
SELECT location,
       Max(Cast(total_cases AS UNSIGNED)) AS Total_case
FROM   coviddeath
WHERE  continent IS NOT NULL AND continent != ''
       AND location = "Bangladesh"
GROUP  BY location;


-- 2. Total death in Bangladesh
SELECT location,
       Max(Cast(total_deaths AS UNSIGNED)) AS Total_death_count
FROM   coviddeath
WHERE  continent IS NOT NULL
       AND location = "Bangladesh"
GROUP  BY location
ORDER  BY total_death_count DESC;


-- 3. Proportion of deaths among confirmed cases (Fatality rate)
with cte as(
SELECT location,
       Max(Cast(total_deaths AS UNSIGNED)) AS Total_death, Max(Cast(total_cases AS UNSIGNED)) AS Total_case
FROM   coviddeath
WHERE  continent IS NOT NULL
       AND location = "Bangladesh"
GROUP  BY location
)
select location, round((Total_death/Total_case)*100, 2) AS Fatality_rate
from cte;



-- 4. Infection Rate - Percentage of population infected
select c.location, v.population, round((Max(Cast(total_cases AS UNSIGNED))/v.population) *100 , 2)AS Infection_rate
from coviddeath c
join vaccination v
on c.iso_code = v.iso_code and c.continent = v.continent
where c.continent is not null and c.continent != ''
and c.location = 'Bangladesh'
group by c.location, v.population;


-- 5. Top 20 Countries with highest confirmed cases with infection rate
SELECT c.location,
       v.population,
       Max(Cast(total_cases AS UNSIGNED)) AS Total_case,
       ROUND(( Max(Cast(total_cases AS UNSIGNED)) / v.population ) * 100 , 2) AS Infection_rate
FROM   coviddeath c
       JOIN vaccination v
         ON c.iso_code = v.iso_code
            AND c.continent = v.continent
            AND c.date = v.date
            AND c.location = v.location
WHERE  c.continent IS NOT NULL
       AND c.continent != ''
GROUP  BY c.location,
          v.population
ORDER  BY total_case DESC
LIMIT  20; 


-- 6. Top 10 countries with maximum death count per population
SELECT location,
       Max(Cast(total_deaths AS UNSIGNED)) AS Total_death
FROM   coviddeath
WHERE  continent IS NOT NULL
       AND continent != ''
GROUP  BY location
ORDER  BY total_death DESC
LIMIT  10; 


-- 7. Total death by continent 
select continent, MAX(CAST(total_deaths AS unsigned)) AS Total_death
from coviddeath
where continent is not null and continent != ''
group by continent
order by Total_death desc;


-- 8. Global case trend 2020 to 2024
SELECT date,
       Sum(new_cases) AS total_case,
       Sum(Cast(new_deaths AS UNSIGNED)) AS total_death,
       Round(Sum(Cast(new_deaths AS UNSIGNED)) / Sum(new_cases) * 100, 2) AS Death_Percentage
FROM   coviddeath
WHERE  continent IS NOT NULL
       AND continent != ''
GROUP  BY date
ORDER  BY STR_TO_DATE(date, '%D/%M/%Y') ASC;


-- 9. Total population VS vaccination in each day
select c.date, c.continent, c.location, v.population, v.new_vaccinations
from coviddeath c
join vaccination v
	on c.location = v.location
	and c.date = v.date
where c.continent is not null and c.continent != ''
ORDER  BY c.continent, STR_TO_DATE(c.date, '%D/%M/%Y') ASC;


-- 10. PERCENTAGE OF POPULATION THAT HAS RECEIVED AT LEAST ONE COVID VACCINE IN Bangladesh

SELECT c.continent,
       c.location,
       c.date,
       v.population,
       v.new_vaccinations,
       Sum(Cast(v.new_vaccinations AS UNSIGNED))
         OVER (
           partition BY c.location
           ORDER BY c.location, c.date) AS RollingPeopleVaccinated
FROM   coviddeath c
       JOIN vaccination v
         ON c.location = v.location
            AND c.date = v.date
WHERE  c.continent IS NOT NULL
       AND c.location = 'Bangladesh'
ORDER  BY 2, 3;
