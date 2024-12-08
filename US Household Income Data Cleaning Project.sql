/*

														US Houshold Income Data Cleaning Project
														
This project involves cleaning and preparing two datasets: US Household Income and US Household Income Statistics. The primary focus is on correcting inconsistencies, removing duplicates, and ensuring data integrity. This project uses PostgreSQL for database management and data cleaning.

*/




CREATE TABLE US_Household_Income ( --Based on the USHouseholdIncome.csv file, I created this table and imported the date from the csv file
                                    row_id INT,
                                      "id" INT,
                                State_Code INT,
                        State_Name VARCHAR(50),
                              State_ab CHAR(2),
                           County VARCHAR(100),
                             City VARCHAR(100),
                            Place VARCHAR(100),
                            "Type" VARCHAR(50),
                         "Primary" VARCHAR(50),
                                  Zip_Code INT,
                         Area_Code VARCHAR(10),
                                  ALand BIGINT,
                                 AWater BIGINT,
                                     Lat FLOAT,
                                     Lon FLOAT
                                );

SELECT * FROM US_Household_Income; --This query was used to verify that all data from csv file was imported susccessfully into the table

CREATE TABLE USHouseholdIncome_Statistics ( --Based on the USHouseholdIncome_Statistics.csv file, I created I created this table and imported the date from the csv file
    id BIGINT PRIMARY KEY,
    State_Name VARCHAR(255),
    Mean FLOAT,
    Median FLOAT,
    Stdev FLOAT,
    sum_w FLOAT
);

SELECT * FROM USHouseholdIncome_Statistics; --This query was used to verify that all data from csv file was imported susccessfully into the table

SELECT COUNT(id) --This query was used to count the rows of the id in comparison to the number of rows in the USHouseholdIncome.csv file
FROM US_Household_Income;

SELECT COUNT(id) --This query was used to count the rows of the id in comparison to the number of rows in the USHouseholdIncome_Statistics.csv file
FROM USHouseholdIncome_Statistics;

select id --This query was used to identify duplicate values in the id column from the US_Household_Income table
     , count(id)
from US_Household_Income
              group by id
                     having count(id) > 1;

SELECT * --This query was used to identify duplicate values in the id column from the US_Household_Income table
FROM
       (SELECT row_id
               , id
               , row_number() OVER(PARTITION BY id ORDER BY id) row_num
        FROM US_Household_Income
       ) duplicates
WHERE row_num > 1 ;

DELETE FROM US_Household_Income --This query was used to remove duplicate data values from the ID column
WHERE row_id IN (
                  SELECT row_id
                  FROM (
                          SELECT row_id
                               , ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS row_num
                          FROM US_Household_Income
                       ) duplicates_data
                   WHERE row_num > 1
                 );

select id --This query was used to identify duplicate values in the id column from the USHouseholdIncome_Statistics table
     , count(id)
from USHouseholdIncome_Statistics
         group by id
              having count(id) > 1;
			  
SELECT state_name --This query was used to identify any spelling mistakes in the state names such as lower capitalization or misspelling
      , COUNT(state_name)
FROM US_Household_Income
                  GROUP BY state_name
	                       ORDER BY state_name ASC;
						   
UPDATE US_Household_Income --This query was used to correct and update the misspelling and in correct capitalization in certain state names
SET state_name = CASE
    WHEN state_name = 'georia' THEN 'Georgia'
	WHEN state_name = 'alabama' THEN 'Alabama'
	ELSE state_name
END
WHERE state_name IN ('georia', 'alabama');

SELECT * --This query was used to identify any null values or missing strings in the place column
    FROM US_Household_Income
           WHERE place IS NULL OR place ='';  

SELECT * --There is a missing value in the place column for the row that has id 102216 and city Vinemont
     FROM US_Household_Income
              WHERE county = 'Autauga County'
                                    ORDER BY 1;

UPDATE US_Household_Income --This query updated the missing value with 'Autaugaville' in the place column  
          SET Place='Autaugaville'
                       WHERE county ='Autauga County'
                                            AND city = 'Vinemont';

SELECT "Type" --This query was to check the variations included in the type column
       , COUNT("Type")
FROM US_Household_Income
GROUP BY "Type";

UPDATE US_Household_Income --This query updated the table with the correct spelling of village and borough
SET "Type" = CASE
    WHEN "Type" = 'village' THEN 'Village'
	WHEN "Type" = 'Boroughs' THEN 'Borough'
	ELSE "Type"
END
WHERE "Type" IN ('village', 'Boroughs');

SELECT aland --This query checks for the numeric value of 0 or if the row is populated with no value
      , awater
        FROM US_Household_Income
                        WHERE awater = 0
				  OR awater IS NULL;
				  
SELECT DISTINCT awater --This query used the DISTINCT function to make sure that there is no blank or null data in the awater column
      FROM US_Household_Income
                        WHERE awater = 0
				                       OR awater IS NULL;
				  
SELECT aland --This query checked to make sure that the data is correct for awater and aland. Some states have more water than land and vice versa.
      ,awater
          FROM US_Household_Income
                        WHERE aland = 0 OR aland IS NULL;