# Analyzing Global COVID-19 Data using SQL

In this project, I leveraged MySQL  to analyze global COVID-19 data, focusing on deaths and vaccination statistics. Key tasks included comprehensive data preparation, calculation of vital metrics, and employing advanced SQL techniques for data integration and analysis. The analysis encompassed several critical aspects:

## Action

 To complete this project, I downloaded the data in CSV format from “[Coronavirus (COVID-19) Deaths - Our World in Data](https://ourworldindata.org/covid-deaths).”  After downloading, I created a Covid database and inserted the CSV data into it. The dataset includes information on COVID-19 deaths and vaccinations, which is regularly updated with the most recent official numbers from governments and health ministries worldwide. The current project data is updated as of July 18, 2024.

After setting up the database, I wrote SQL queries to find answers to each of the questions mentioned above. Queries included simple SELECT statements to advance CTEs, Joins, Views, etc.

## Analysis

The COVID-19 pandemic has been a global crisis that has affected millions of people worldwide. 

In this project, I leveraged MS SQL Server to analyze global COVID-19 data, focusing on deaths and vaccination statistics. Key tasks included comprehensive data preparation, calculation of vital metrics, and employing advanced SQL techniques for data integration and analysis. The analysis encompassed several critical aspects includes:

# Snippet of Code
    
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
