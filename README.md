# Project Summary: Analyzing Global COVID-19 Data using SQL

In this project, I leveraged MS SQL Server to analyze global COVID-19 data, focusing on deaths and vaccination statistics. Key tasks included comprehensive data preparation, calculation of vital metrics, and employing advanced SQL techniques for data integration and analysis. The analysis encompassed several critical aspects:

## Action

 To complete this project, I downloaded the data in CSV format from “[Coronavirus (COVID-19) Deaths - Our World in Data](https://ourworldindata.org/covid-deaths).”  After downloading, I created a Covid database and inserted the CSV data into it. The dataset includes information on COVID-19 deaths and vaccinations, which is regularly updated with the most recent official numbers from governments and health ministries worldwide. The current project data is updated as of July 18, 2024.

After setting up the database, I wrote SQL queries to find answers to each of the questions mentioned above. Queries included simple SELECT statements to advance CTEs, Joins, Views, etc.

## Analysis

The COVID-19 pandemic has been a global crisis that has affected millions of people worldwide. 

In this project, I leveraged MS SQL Server to analyze global COVID-19 data, focusing on deaths and vaccination statistics. Key tasks included comprehensive data preparation, calculation of vital metrics, and employing advanced SQL techniques for data integration and analysis. The analysis encompassed several critical aspects includes:

- **Total Case in Bangladesh**
    
    
    ```sql
    SELECT location,
           Max(Cast(total_cases AS UNSIGNED)) AS Total_case
    FROM   coviddeath
    WHERE  continent IS NOT NULL AND continent != ''
           AND location = "Bangladesh"
    GROUP  BY location;
    ```
    
    ![total case in bangladesh.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/77cc108b-6d3d-49ab-b4c1-489af754bd3a/total_case_in_bangladesh.png)
    
- **Total Death in Bangladesh**
    
    
    ```sql
    SELECT location,
           Max(Cast(total_deaths AS UNSIGNED)) AS Total_death_count
    FROM   coviddeath
    WHERE  continent IS NOT NULL
           AND location = "Bangladesh"
    GROUP  BY location
    ORDER  BY total_death_count DESC;
    ```
    
    ![bangladesh total death in covid.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/d2d8caa9-cf43-464e-bcb8-f196cf143294/bangladesh_total_death_in_covid.png)
    
- **Fatality Rate (Percentage of death among confirmed cases in Bangladesh)**
    
    
    ```sql
    WITH cte
         AS (SELECT location,
                    Max(Cast(total_deaths AS UNSIGNED)) AS Total_death,
                    Max(Cast(total_cases AS UNSIGNED))  AS Total_case
             FROM   coviddeath
             WHERE  continent IS NOT NULL
                    AND location = "bangladesh"
             GROUP  BY location)
    SELECT location,
           Round(( total_death / total_case ) * 100, 2) AS Fatality_rate
    FROM   cte;
    ```
    
    ![Fatality rate.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/ef7b203a-ad7d-4661-962e-804c6a23abd6/Fatality_rate.png)
    
- **Infection Rate (Percentage of infected people among population)**
    
    ```sql
    SELECT c.location,
           v.population,
           Round(( Max(Cast(total_cases AS UNSIGNED)) / v.population ) * 100, 2)AS
           Infection_rate
    FROM   coviddeath c
           JOIN vaccination v
             ON c.iso_code = v.iso_code
                AND c.continent = v.continent
    WHERE  c.continent IS NOT NULL
           AND c.continent != ''
           AND c.location = 'Bangladesh'
    GROUP  BY c.location,
              v.population;
    ```
    
    ![infection rate.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/12888b4a-501a-448d-86b4-f0b0af4f1d68/infection_rate.png)
    
- **Number of people that has received at least one covid vaccination in Bangladesh**
    
    ```sql
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
    ```
    
    ![rolling vaccination trend.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/c7291060-b055-4b83-a75d-233b0d73fc52/rolling_vaccination_trend.png)
    
- **Top 20 countries with highest confirmed cases with infection rate**
    
    ```sql
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
    ```
    
    ![Top infected country.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/3d585e7a-8639-4b41-b3db-8b10b4fcaf88/Top_infected_country.png)
    
- **Top 10 countries with maximum death count per population**
    
    ```sql
    SELECT location,
           Max(Cast(total_deaths AS UNSIGNED)) AS Total_death
    FROM   coviddeath
    WHERE  continent IS NOT NULL
           AND continent != ''
    GROUP  BY location
    ORDER  BY total_death DESC
    LIMIT  10;
    ```
    
    ![top 10 highest death.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/c06a4a43-c578-4e1b-88b9-becff25a14dd/top_10_highest_death.png)
    
- **Total death by continent**
    
    ```sql
    SELECT continent,
           Max(Cast(total_deaths AS UNSIGNED)) AS Total_death
    FROM   coviddeath
    WHERE  continent IS NOT NULL
           AND continent != ''
    GROUP  BY continent
    ORDER  BY total_death DESC;
    ```
    
    ![total death by continent.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/bf056ac4-5f08-4a90-8f57-5abf22bdb7b1/total_death_by_continent.png)
    
- **Global case trend 2020 to 2024**
    
    ```sql
    SELECT date,
           Sum(new_cases) AS total_case,
           Sum(Cast(new_deaths AS UNSIGNED)) AS total_death,
           Round(Sum(Cast(new_deaths AS UNSIGNED)) / Sum(new_cases) * 100, 2) AS Death_Percentage
    FROM   coviddeath
    WHERE  continent IS NOT NULL
           AND continent != ''
    GROUP  BY date
    ORDER  BY STR_TO_DATE(date, '%D/%M/%Y') ASC;
    ```
    
    ![global trend.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/562839a6-5285-494f-80c9-7f950d9c6ce6/global_trend.png)
    
- **Global vaccination vs population**
    
    
    ```sql
    SELECT c.date,
           c.continent,
           c.location,
           v.population,
           v.new_vaccinations
    FROM   coviddeath c
           JOIN vaccination v
             ON c.location = v.location
                AND c.date = v.date
    WHERE  c.continent IS NOT NULL
           AND c.continent != ''
    ORDER  BY c.continent,
              Str_to_date(c.date, '%D/%M/%Y') ASC; 
    ```
    
    ![vaccination trend.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/d774bcbe-f015-4aa5-b102-7b4ccde4ab34/919c3c49-374a-42a7-a39f-7f4dce19e3e2/vaccination_trend.png)
    

## Findings

- As of this point, Bangladesh has recorded a total of **2,050,834** confirmed COVID-19 cases. This figure represents the cumulative number of individuals who have tested positive for the virus since the beginning of the pandemic in the country.
- Tragically, the pandemic has claimed the lives of **29,496** people in Bangladesh. This number underscores the severity of the disease and its impact on the population.
- The **case fatality rate (CFR)** is a measure of the proportion of confirmed cases that result in death. In the case of Bangladesh, the CFR stands at **1.44%**. This indicates that approximately 1.44% of individuals diagnosed with COVID-19 in the country have succumbed to the disease.
- The **infection rate** refers to the proportion of the population that has contracted the disease. In this case, the infection rate of **1.2%** suggests that approximately 1.2% of the Bangladeshi population has been infected with COVID-19.
- The United States has the highest number of deaths, followed by Brazil, India, and Russia.
- **United States**: With a population of 338 million, the US has reported 103 million cases, resulting in an infection rate of 30.58%.
- **China**: Despite its large population (1.4 billion), China has managed to keep infections relatively low (99 million cases, 6.97% infection rate).
- **India**: India’s population of 1.4 billion faces a significant challenge, with 45 million cases (3.18% infection rate).
- **France**, **Germany**, and **Brazil** follow closely, each with varying infection rates.
- **South Korea**, **Japan**, and **Italy** have managed to control the spread effectively.
- The impact of COVID-19 has been profound across different continents. **North America** has the highest death toll, reporting **1,189,083** fatalities. **South America** follows closely with **702,116** deaths. **Asia** reports **533,619** deaths, while **Europe** has lost **403,031** lives due to the pandemic. **Africa**, too, has been affected, with **102,595** deaths. The smallest number of deaths is in **Oceania**, where **25,236** lives have been lost.

## Impact

This analysis provided crucial insights into COVID-19 total case, deaths, infection rates, fatality rates within Bangladesh, highest infected country, maximum death and vaccination progress worldwide. By facilitating informed decision-making and targeted health interventions, the project contributed to managing the pandemic effectively on a global scale.

## Reflection

This project taught me the importance of SQL in manipulating and extracting necessary data for ad hoc analysis. In the future, I plan to incorporate more real-time data sources and pull necessary data for further analysis and ad hoc queries using SQL, while also focusing on improving data quality.
