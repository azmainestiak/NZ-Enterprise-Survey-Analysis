CREATE TABLE annual_enterprise_survey_2025 (
    year INTEGER,
    industry_aggregation_nzsioc VARCHAR(50),
    industry_code_nzsioc VARCHAR(10),
    industry_name_nzsioc TEXT,
    units VARCHAR(50),
    variable_code VARCHAR(10),
    variable_name TEXT,
    variable_category VARCHAR(100),
    value NUMERIC(18,2),
    industry_code_anzsic06 TEXT
);

select * from annual_enterprise_survey_2024;


--How many total records are in the table?

select count(*) from annual_enterprise_survey_2024;

--How many distinct industries are present?

select count(distinct industry_name_nzsioc)
from annual_enterprise_survey_2024;



--How many unique variable categories exist?

select distinct variable_category
from annual_enterprise_survey_2024;


--What are the distinct years available in the dataset?
select * from annual_enterprise_survey_2024;

select distinct year
from annual_enterprise_survey_2024
group by year;



--List all industries under the NZSIOC Level 1 aggregation.
select * from annual_enterprise_survey_2024;

SELECT DISTINCT industry_name_nzsioc
FROM annual_enterprise_survey_2024
WHERE industry_aggregation_nzsioc = 'Level 1';



--What is the total value for each industry?
select * from annual_enterprise_survey_2024;

select industry_name_nzsioc, sum(value)
from annual_enterprise_survey_2024
group by industry_name_nzsioc;

--Which industry has the highest total value?

SELECT industry_name_nzsioc, SUM(value) AS total_value
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc
ORDER BY total_value DESC
LIMIT 1;

--What is the average value per variable category?

select variable_category, avg(value)
from annual_enterprise_survey_2024
group by variable_category;




--How many records exist for each year?

select year, count(*)
from annual_enterprise_survey_2024
group by year
order by year;

--Which variables are measured in dollars?
select * from annual_enterprise_survey_2024;
SELECT DISTINCT variable_name
FROM annual_enterprise_survey_2024
WHERE units ILIKE '%dollar%';


--What is the total value of Total income by industry?

 SELECT industry_name_nzsioc, SUM(value) AS total_income
FROM annual_enterprise_survey_2024
WHERE variable_name = 'Total income'
GROUP BY industry_name_nzsioc;


--Which industry has the highest Total income?

SELECT industry_name_nzsioc, SUM(value) AS total_income
FROM annual_enterprise_survey_2024
WHERE variable_name = 'Total income'
GROUP BY industry_name_nzsioc
ORDER BY total_income DESC
LIMIT 1;


--What is the total expenditure for each industry?

SELECT industry_name_nzsioc, SUM(value) AS total_expenditure
FROM annual_enterprise_survey_2024
WHERE variable_name ILIKE '%expenditure%'
GROUP BY industry_name_nzsioc;


--What is the average value for each variable?
SELECT variable_name, AVG(value) AS avg_value
FROM annual_enterprise_survey_2024
GROUP BY variable_name;



--Which industry has the highest number of records?

SELECT industry_name_nzsioc, COUNT(*) AS record_count
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc
ORDER BY record_count DESC
LIMIT 1;


--List industries where the value is NULL.

SELECT DISTINCT industry_name_nzsioc
FROM annual_enterprise_survey_2024
WHERE value IS NULL;


--How many variables belong to each variable category?

SELECT variable_category, COUNT(DISTINCT variable_name) AS variable_count
FROM annual_enterprise_survey_2024
GROUP BY variable_category;


--What is the minimum and maximum value for each variable?

SELECT variable_name,
       MIN(value) AS min_value,
       MAX(value) AS max_value
FROM annual_enterprise_survey_2024
GROUP BY variable_name;


--Find industries where total value exceeds 1 billion.

SELECT industry_name_nzsioc, SUM(value) AS total_value
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc
HAVING SUM(value) > 1000000000;


--Rank industries by total value.

SELECT industry_name_nzsioc,
       SUM(value) AS total_value,
       RANK() OVER (ORDER BY SUM(value) DESC) AS rank
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc;


--What is the year-over-year change in total value by industry?

SELECT industry_name_nzsioc,
       year,
       SUM(value) -
       LAG(SUM(value)) OVER (
           PARTITION BY industry_name_nzsioc
           ORDER BY year
       ) AS yoy_change
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc, year;



--Which variable shows the highest growth across years?

SELECT variable_name,
       MAX(value) - MIN(value) AS growth
FROM annual_enterprise_survey_2024
GROUP BY variable_name
ORDER BY growth DESC
LIMIT 1;


--Calculate the percentage contribution of each industry to total value.
SELECT industry_name_nzsioc,
       SUM(value) * 100.0 /
       (SELECT SUM(value) FROM annual_enterprise_survey_2024) AS percentage_contribution
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc;



--Identify industries with declining values over years.

SELECT DISTINCT industry_name_nzsioc
FROM (
    SELECT industry_name_nzsioc,
           year,
           SUM(value) -
           LAG(SUM(value)) OVER (
               PARTITION BY industry_name_nzsioc
               ORDER BY year
           ) AS diff
    FROM annual_enterprise_survey_2024
    GROUP BY industry_name_nzsioc, year
) t
WHERE diff < 0;


--What is the cumulative value by industry over time?

SELECT industry_name_nzsioc,
       year,
       SUM(SUM(value)) OVER (
           PARTITION BY industry_name_nzsioc
           ORDER BY year
       ) AS cumulative_value
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc, year;



--Which industries have values recorded in multiple units?

SELECT industry_name_nzsioc
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc
HAVING COUNT(DISTINCT units) > 1;


--Find duplicate records based on industry, year, and variable.

SELECT industry_name_nzsioc, year, variable_name, COUNT(*)
FROM annual_enterprise_survey_2024
GROUP BY industry_name_nzsioc, year, variable_name
HAVING COUNT(*) > 1;


--Which variable has the most missing values?

SELECT variable_name, COUNT(*) AS null_count
FROM annual_enterprise_survey_2024
WHERE value IS NULL
GROUP BY variable_name
ORDER BY null_count DESC
LIMIT 1;


--Create a view summarizing total value by year and industry.

CREATE VIEW industry_year_summary AS
SELECT year,
       industry_name_nzsioc,
       SUM(value) AS total_value
FROM annual_enterprise_survey_2024
GROUP BY year, industry_name_nzsioc;


--Identify outliers where values deviate significantly from industry averages.
SELECT *
FROM annual_enterprise_survey_2024 a
WHERE value >
(
    SELECT AVG(value) + 2 * STDDEV(value)
    FROM annual_enterprise_survey_2024 b
    WHERE a.industry_name_nzsioc = b.industry_name_nzsioc
);

