-- Set the current database to 'logistics_project'
USE logistics_project;

-- Create the main table to store the raw logistics data
CREATE TABLE logistics_data (
  -- Define columns and their data types based on the dataset's features
  `Timestamp` DATETIME,
  `Vehicle GPS Latitude` DOUBLE,
  `Vehicle GPS Longitude` DOUBLE,
  `Fuel Consumption Rate` DOUBLE,
  `ETA Variation (hours)` DOUBLE,
  `Traffic Congestion Level` DOUBLE,
  `Warehouse Inventory Level` DOUBLE,
  `Loading/Unloading Time` DOUBLE,
  `Handling Equipment Availability` INT,
  `Order Fulfillment Status` INT,
  `Weather Condition Severity` DOUBLE,
  `Port Congestion Level` DOUBLE,
  `Shipping Costs` DOUBLE,
  `Supplier Reliability Score` DOUBLE,
  `Lead Time (days)` DOUBLE,
  `Historical Demand` DOUBLE,
  `IoT Temperature` DOUBLE,
  `Cargo Condition Status` INT,
  `Route Risk Level` DOUBLE,
  `Customs Clearance Time` DOUBLE,
  `Driver Behavior Score` DOUBLE,
  `Fatigue Monitoring Score` DOUBLE,
  `Disruption Likelihood Score` DOUBLE,
  `Delay Probability` DOUBLE,
  `Risk Classification` VARCHAR(255),
  `Delivery Time Deviation` DOUBLE
);

-- Show the secure file path to which MySQL is restricted for data loading
SHOW VARIABLES LIKE 'secure_file_priv';

-- Load data from a CSV file into the 'logistics_data' table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dynamic_supply_chain_logistics_dataset.csv'
INTO TABLE logistics_data
FIELDS TERMINATED BY ',' -- Fields in the CSV are separated by a comma
ENCLOSED BY '"' -- Values are enclosed in double quotes
LINES TERMINATED BY '\n' -- Each new line indicates a new record
IGNORE 1 ROWS; -- Skip the first row of the CSV, as it contains column headers

-- Select the first 10 records from the table to verify data was loaded correctly
SELECT
  *
FROM
  logistics_data
LIMIT 10;

-- Analyze delivery performance by categorizing delays and calculating average costs
SELECT
  CASE -- Create a new column to categorize deliveries based on deviation
    WHEN `Delivery Time Deviation` <= 0 THEN 'On Time'
    WHEN `Delivery Time Deviation` > 0 AND `Delivery Time Deviation` <= 5 THEN 'Slight Delay'
    ELSE 'Major Delay'
  END AS Delay_Category,
  COUNT(*) AS Number_of_Deliveries, -- Count the total number of deliveries in each category
  AVG(`Shipping Costs`) AS Avg_Shipping_Cost, -- Calculate the average shipping cost for each category
  AVG(`Fuel Consumption Rate`) AS Avg_Fuel_Consumption -- Calculate the average fuel consumption for each category
FROM
  logistics_data
GROUP BY
  Delay_Category -- Group the results by the new category
ORDER BY
  Avg_Shipping_Cost DESC; -- Order the results by average shipping cost, from highest to lowest

-- Analyze the relationship between route risk and delivery metrics
SELECT
  `Route Risk Level`,
  COUNT(*) AS Total_Deliveries,
  AVG(`Shipping Costs`) AS Avg_Shipping_Cost,
  AVG(`Delivery Time Deviation`) AS Avg_Delivery_Deviation_Hours
FROM
  logistics_data
GROUP BY
  `Route Risk Level` -- Group the results by the route's risk level
ORDER BY
  `Route Risk Level` DESC;

-- Analyze order fulfillment status against warehouse inventory levels
SELECT
  `Warehouse Inventory Level`,
  COUNT(*) AS Total_Orders,
  SUM(CASE WHEN `Order Fulfillment Status` = 1 THEN 1 ELSE 0 END) AS Fulfilled_Orders, -- Count fulfilled orders (status = 1)
  SUM(CASE WHEN `Order Fulfillment Status` = 0 THEN 1 ELSE 0 END) AS Unfulfilled_Orders -- Count unfulfilled orders (status = 0)
FROM
  logistics_data
GROUP BY
  `Warehouse Inventory Level` -- Group results by inventory level
ORDER BY
  `Warehouse Inventory Level` DESC;

-- Analyze the impact of external factors (traffic and weather) on delivery delays
SELECT
  `Traffic Congestion Level`,
  `Weather Condition Severity`,
  COUNT(*) AS Total_Events,
  AVG(`Delivery Time Deviation`) AS Avg_Delay_Hours,
  AVG(`Shipping Costs`) AS Avg_Shipping_Costs
FROM
  logistics_data
GROUP BY
  `Traffic Congestion Level`,
  `Weather Condition Severity` -- Group results by both congestion and weather
ORDER BY
  `Avg_Delay_Hours` DESC;

-- Create a dimension table for time attributes from the main data
CREATE TABLE Dim_Time AS
SELECT
    DISTINCT DATE(`Timestamp`) AS `Date`,
    YEAR(`Timestamp`) AS `Year`,
    MONTH(`Timestamp`) AS `Month`,
    DAYOFMONTH(`Timestamp`) AS `Day`,
    DAYOFWEEK(`Timestamp`) AS `DayOfWeek`
FROM
    logistics_data;

-- Create a dimension table for route attributes
CREATE TABLE Dim_Routes AS
SELECT
    DISTINCT `Route Risk Level`,
    `Traffic Congestion Level`,
    `Weather Condition Severity`
FROM
    logistics_data;

-- Create a dimension table for supplier attributes
CREATE TABLE Dim_Suppliers AS
SELECT
    DISTINCT `Supplier Reliability Score`,
    `Lead Time (days)`
FROM
    logistics_data;

-- Create the central fact table, linking to dimension tables
CREATE TABLE Fact_Deliveries AS
SELECT
    A.`Shipping Costs`,
    A.`Delivery Time Deviation`,
    A.`ETA Variation (hours)`,
    A.`Fuel Consumption Rate`,
    A.`Historical Demand`,
    A.`Loading/Unloading Time`,
    A.`Order Fulfillment Status`,
    A.`Port Congestion Level`,
    A.`Customs Clearance Time`,
    B.`Date` AS `Time_Key`, -- Foreign key to Dim_Time
    C.`Route Risk Level`, -- Attributes from Dim_Routes
    C.`Traffic Congestion Level`,
    C.`Weather Condition Severity`
FROM
    logistics_data AS A
INNER JOIN
    Dim_Time AS B ON DATE(A.`Timestamp`) = B.`Date`
INNER JOIN
    Dim_Routes AS C ON A.`Route Risk Level` = C.`Route Risk Level`;

-- Use a window function to calculate a 7-day rolling average for delivery deviation
SELECT
    B.Date,
    A.`Delivery Time Deviation`,
    AVG(A.`Delivery Time Deviation`) OVER (ORDER BY B.Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling_7_Day_Avg_Deviation
FROM
    Fact_Deliveries AS A
INNER JOIN
    Dim_Time AS B ON A.Time_Key = B.Date;

-- Use a window function to find the previous day's delivery deviation
SELECT
    B.Date,
    A.`Delivery Time Deviation`,
    LAG(A.`Delivery Time Deviation`, 1, 0) OVER (ORDER BY B.Date) AS Previous_Day_Deviation
FROM
    Fact_Deliveries AS A
INNER JOIN
    Dim_Time AS B ON A.Time_Key = B.Date;

-- Create a new table with engineered features for predictive analysis
CREATE TABLE fact_deliveries_features AS
SELECT
    A.*,
    CASE -- Create a binary flag for weekend vs. weekday
        WHEN DAYOFWEEK(B.Date) IN (1, 7) THEN 1
        ELSE 0
    END AS Is_Weekend,
    CASE -- Categorize deliveries by time of day
        WHEN HOUR(A.Timestamp) BETWEEN 6 AND 12 THEN 'Morning'
        WHEN HOUR(A.Timestamp) BETWEEN 12 AND 18 THEN 'Afternoon'
        ELSE 'Night'
    END AS Time_of_Day_Category,
    LAG(A.`Delivery Time Deviation`, 1, 0) OVER (ORDER BY B.Date) AS Previous_Day_Deviation -- Use LAG to get the previous day's deviation
FROM
    logistics_data AS A
INNER JOIN
    Dim_Time AS B ON DATE(A.Timestamp) = B.Date;

-- Verify the new 'Is_Weekend' feature
SELECT
  Is_Weekend,
  COUNT(*) AS `Total_Deliveries`
FROM
  fact_deliveries_features
GROUP BY
  Is_Weekend;

-- Verify the new 'Time_of_Day_Category' feature
SELECT
  Time_of_Day_Category,
  COUNT(*) AS `Total_Deliveries`
FROM
  fact_deliveries_features
GROUP BY
  Time_of_Day_Category;

-- Verify the new 'Previous_Day_Deviation' feature
SELECT
  Timestamp,
  `Delivery Time Deviation`,
  Previous_Day_Deviation
FROM
  fact_deliveries_features
ORDER BY
  Timestamp
LIMIT 10;

-- Export data with headers for Tableau, used in the final visualization part
(SELECT
  'Timestamp',
  'Vehicle GPS Latitude',
  'Vehicle GPS Longitude',
  'Fuel Consumption Rate',
  'ETA Variation (hours)',
  'Traffic Congestion Level',
  'Warehouse Inventory Level',
  'Loading/Unloading Time',
  'Handling Equipment Availability',
  'Order Fulfillment Status',
  'Weather Condition Severity',
  'Port Congestion Level',
  'Shipping Costs',
  'Supplier Reliability Score',
  'Lead Time (days)',
  'Historical Demand',
  'IoT Temperature',
  'Cargo Condition Status',
  'Route Risk Level',
  'Customs Clearance Time',
  'Driver Behavior Score',
  'Fatigue Monitoring Score',
  'Disruption Likelihood Score',
  'Delay Probability',
  'Risk Classification',
  'Delivery Time Deviation'
)
UNION ALL
(SELECT
  `Timestamp`,
  `Vehicle GPS Latitude`,
  `Vehicle GPS Longitude`,
  `Fuel Consumption Rate`,
  `ETA Variation (hours)`,
  `Traffic Congestion Level`,
  `Warehouse Inventory Level`,
  `Loading/Unloading Time`,
  `Handling Equipment Availability`,
  `Order Fulfillment Status`,
  `Weather Condition Severity`,
  `Port Congestion Level`,
  `Shipping Costs`,
  `Supplier Reliability Score`,
  `Lead Time (days)`,
  `Historical Demand`,
  `IoT Temperature`,
  `Cargo Condition Status`,
  `Route Risk Level`,
  `Customs Clearance Time`,
  `Driver Behavior Score`,
  `Fatigue Monitoring Score`,
  `Disruption Likelihood Score`,
  `Delay Probability`,
  `Risk Classification`,
  `Delivery Time Deviation`
FROM
  logistics_data)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/logistics_data_for_tableau.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';