create database Blinkit_db;

CREATE TABLE Blinkit_data (
    Item_Fat_Content VARCHAR(50),
    Item_Identifier VARCHAR(50),
    Item_Type VARCHAR(50),
    Outlet_Establishment_Year INT,
    Outlet_Identifier VARCHAR(50),
    Outlet_Location_Type VARCHAR(50),
    Outlet_Size VARCHAR(50),
    Outlet_Type VARCHAR(50),
    Item_Visibility FLOAT,
    Item_Weight FLOAT,
    Total_Sales FLOAT,
    Rating FLOAT
);

# Safe Mode disabled
SET SQL_SAFE_UPDATES = 0;


UPDATE Blinkit_data
SET Item_Weight = NULLIF(CAST(Item_Weight AS CHAR), 'NULL'),
    Rating = NULLIF(CAST(Rating AS CHAR), 'NULL'),
    Item_Visibility = NULLIF(CAST(Item_Visibility AS CHAR), 'NULL')
WHERE CAST(Item_Weight AS CHAR) = 'NULL' 
   OR CAST(Rating AS CHAR) = 'NULL' 
   OR CAST(Item_Visibility AS CHAR) = 'NULL';

# Safe Mode enabled
SET SQL_SAFE_UPDATES = 1;

# Rows that contains NULL values
SELECT COUNT(*) FROM Blinkit_data WHERE Item_Weight IS NULL;


#To see all the imported data:
SELECT * FROM blinkit_data;

## Data Cleaning:
-- Updating some values of column "Item_Fat_Content":

-- disabled safe Mode due to error-free execution of update command without where clause

SET SQL_SAFE_UPDATES = 0;

UPDATE blinkit_data
SET Item_Fat_Content = 
    CASE 
        WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;

# Safe Mode enabled
SET SQL_SAFE_UPDATES = 1;


# distinct values of "Item_Fat_Content" column:
SELECT DISTINCT Item_Fat_Content FROM blinkit_data;





## KPI: 

#Total Sales in Millions:
SELECT CAST(SUM(Total_Sales)/ 1000000 AS DECIMAL(10,2)) AS Total_Sales_Millions 
FROM blinkit_data;

# Average Sales:
SELECT CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales FROM blinkit_data;

# Number of Items:
SELECT COUNT(*) AS No_Of_Items FROM blinkit_data;

#Average Rating:
SELECT CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating FROM blinkit_data;


#Total Sales by Fat Content:
SELECT Item_Fat_Content,
       CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2)) AS Total_Sales_Thousands
FROM blinkit_data
GROUP BY Item_Fat_Content
ORDER BY Total_Sales_Thousands DESC;

#Total Sales by Item_type:
SELECT Item_type,
       CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_type
ORDER BY Total_Sales DESC;

#Fat Content by Outlet for Total Sales:
SELECT 
    Outlet_Location_Type,
    ROUND(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales ELSE 0 END), 2) AS Low_Fat,
    ROUND(SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales ELSE 0 END), 2) AS Regular
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

# Total Sales by Outlet establishment year:
SELECT 
    Outlet_Establishment_Year,
    ROUND(SUM(Total_Sales), 2) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year ASC;

#Percentage of Sales by Outlet Size:
SELECT 
    Outlet_Size,
    ROUND(SUM(Total_Sales), 2) AS Total_Sales,
    ROUND((SUM(Total_Sales) * 100 / (SELECT SUM(Total_Sales) FROM blinkit_data)), 2) AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

#Sales by Outlet Location:
SELECT 
    Outlet_Location_Type,
    ROUND(SUM(Total_Sales), 2) AS Total_Sales
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Total_Sales DESC;

#All metrices by Outlet_Type:
SELECT 
    Outlet_Type,
    ROUND(SUM(Total_Sales), 2) AS Total_Sales,
    ROUND((SUM(Total_Sales) * 100 / (SELECT SUM(Total_Sales) FROM blinkit_data)), 2) AS Sales_Percentage,
    ROUND(AVG(Total_Sales), 1) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    ROUND(AVG(Rating), 2) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;






