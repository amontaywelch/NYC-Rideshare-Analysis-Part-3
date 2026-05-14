-- Rideshare Pt 3
-- The final part focuses on the impact on the rideshare giants, Uber and Lyft


-- Creating new column to house company names for 2024, confirming column was created correctly
CREATE OR REPLACE TABLE `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS 
  SELECT *,
  CASE
    WHEN hvfhs_license_num = "HV0003" THEN "Uber"
    WHEN hvfhs_license_num = "HV0005" THEN "Lyft"
    ELSE "Other"
  END AS company
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`;

SELECT DISTINCT hvfhs_license_num
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`;


-- Creating new column to house company names for 2025, confirming column was created correctly
CREATE OR REPLACE TABLE `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS 
  SELECT *,
  CASE
    WHEN hvfhs_license_num = "HV0003" THEN "Uber"
    WHEN hvfhs_license_num = "HV0005" THEN "Lyft"
    ELSE "Other"
  END AS company
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`;

SELECT DISTINCT hvfhs_license_num
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`;





-- LAYER 1: MARKET SHARE


-- Total citywide trip volume comparison for Uber
WITH uber_trip_count_2024 AS (
  SELECT
    company,
    COUNT(*) AS total_trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
  GROUP BY company
),
uber_trip_count_2025 AS (
  SELECT
    company,
    COUNT(*) AS total_trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
  GROUP BY company
)
SELECT
  total_trips_2024,
  total_trips_2025,
  (total_trips_2025 - total_trips_2024) AS trip_diff,
  ROUND(((total_trips_2025 - total_trips_2024) / total_trips_2024) * 100, 2) AS growth_pct
FROM uber_trip_count_2024
JOIN uber_trip_count_2025 USING(company);


-- Total citywide trip volume comparison for Lyft
WITH lyft_trip_count_2024 AS (
  SELECT
    company,
    COUNT(*) AS total_trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
  GROUP BY company
),
lyft_trip_count_2025 AS (
  SELECT
    company,
    COUNT(*) AS total_trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
  GROUP BY company
)
SELECT
  total_trips_2024,
  total_trips_2025,
  (total_trips_2025 - total_trips_2024) AS trip_diff,
  ROUND(((total_trips_2025 - total_trips_2024) / total_trips_2024) * 100, 2) AS growth_pct
FROM lyft_trip_count_2024
JOIN lyft_trip_count_2025 USING(company);


-- Uber Manhattan pickups YoY
WITH uber_pu_2024 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_pu_2025 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.total_trips AS pickups_2024,
  b.total_trips AS pickups_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM uber_pu_2024 AS a
CROSS JOIN uber_pu_2025 AS b;


-- Uber Manhattan dropoffs YoY
WITH uber_do_2024 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_do_2025 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.total_trips AS dropoffs_2024,
  b.total_trips AS dropoffs_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM uber_do_2024 AS a
CROSS JOIN uber_do_2025 AS b;


-- Lyft Manhattan pickups YoY
WITH lyft_pu_2024 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_pu_2025 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.total_trips AS pickups_2024,
  b.total_trips AS pickups_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM lyft_pu_2024 AS a
CROSS JOIN lyft_pu_2025 AS b;


-- Lyft Manhattan dropoffs YoY
WITH lyft_do_2024 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_do_2025 AS (
  SELECT COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.total_trips AS dropoffs_2024,
  b.total_trips AS dropoffs_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM lyft_do_2024 AS a
CROSS JOIN lyft_do_2025 AS b;


-- 2025 congestion zone trips for Uber
SELECT
  company,
  COUNT(*) AS congestion_zone_trips,
  ROUND(SUM(cbd_congestion_fee), 2) AS total_fees_collected,
  ROUND(AVG(cbd_congestion_fee), 2) AS avg_fee_per_trip
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
WHERE company = 'Uber'
  AND cbd_congestion_fee > 0
GROUP BY company;


-- 2025 congestion zone trips for Lyft
SELECT
  company,
  COUNT(*) AS congestion_zone_trips,
  ROUND(SUM(cbd_congestion_fee), 2) AS total_fees_collected,
  ROUND(AVG(cbd_congestion_fee), 2) AS avg_fee_per_trip
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
WHERE company = 'Lyft'
  AND cbd_congestion_fee > 0
GROUP BY company;




-- LAYER 2: REVENUE & EARNINGS


-- Uber citywide revenue comparison
WITH uber_2024 AS (
  SELECT
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(base_passenger_fare) - SUM(driver_pay), 2) AS net_revenue,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(tips), 2) AS total_tips,
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
),
uber_2025 AS (
  SELECT
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(base_passenger_fare) - SUM(driver_pay), 2) AS net_revenue,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(tips), 2) AS total_tips,
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
)
SELECT
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS gross_bookings_growth_pct,
  a.net_revenue AS net_revenue_2024,
  b.net_revenue AS net_revenue_2025,
  ROUND(((b.net_revenue - a.net_revenue) / a.net_revenue) * 100, 2) AS net_revenue_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct,
  a.total_tips AS tips_2024,
  b.total_tips AS tips_2025,
  ROUND(((b.total_tips - a.total_tips) / a.total_tips) * 100, 2) AS tips_growth_pct,
  a.total_driver_earnings AS driver_earnings_2024,
  b.total_driver_earnings AS driver_earnings_2025,
  ROUND(((b.total_driver_earnings - a.total_driver_earnings) / a.total_driver_earnings) * 100, 2) AS driver_earnings_growth_pct
FROM uber_2024 AS a
CROSS JOIN uber_2025 AS b;


-- Lyft citywide revenue comparison
WITH lyft_2024 AS (
  SELECT
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(base_passenger_fare) - SUM(driver_pay), 2) AS net_revenue,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(tips), 2) AS total_tips,
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
),
lyft_2025 AS (
  SELECT
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(base_passenger_fare) - SUM(driver_pay), 2) AS net_revenue,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(tips), 2) AS total_tips,
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
)
SELECT
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS gross_bookings_growth_pct,
  a.net_revenue AS net_revenue_2024,
  b.net_revenue AS net_revenue_2025,
  ROUND(((b.net_revenue - a.net_revenue) / a.net_revenue) * 100, 2) AS net_revenue_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct,
  a.total_tips AS tips_2024,
  b.total_tips AS tips_2025,
  ROUND(((b.total_tips - a.total_tips) / a.total_tips) * 100, 2) AS tips_growth_pct,
  a.total_driver_earnings AS driver_earnings_2024,
  b.total_driver_earnings AS driver_earnings_2025,
  ROUND(((b.total_driver_earnings - a.total_driver_earnings) / a.total_driver_earnings) * 100, 2) AS driver_earnings_growth_pct
FROM lyft_2024 AS a
CROSS JOIN lyft_2025 AS b;


-- Uber Manhattan pickup revenue YoY
WITH uber_pu_2024 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_pu_2025 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS gross_bookings_growth_pct,
  a.net_revenue AS net_revenue_2024,
  b.net_revenue AS net_revenue_2025,
  ROUND(((b.net_revenue - a.net_revenue) / a.net_revenue) * 100, 2) AS net_revenue_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct,
  a.total_tips AS tips_2024,
  b.total_tips AS tips_2025,
  ROUND(((b.total_tips - a.total_tips) / a.total_tips) * 100, 2) AS tips_growth_pct,
  a.total_driver_earnings AS driver_earnings_2024,
  b.total_driver_earnings AS driver_earnings_2025,
  ROUND(((b.total_driver_earnings - a.total_driver_earnings) / a.total_driver_earnings) * 100, 2) AS driver_earnings_growth_pct
FROM uber_pu_2024 AS a
CROSS JOIN uber_pu_2025 AS b;


-- Uber Manhattan dropoff revenue YoY
WITH uber_do_2024 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_do_2025 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS gross_bookings_growth_pct,
  a.net_revenue AS net_revenue_2024,
  b.net_revenue AS net_revenue_2025,
  ROUND(((b.net_revenue - a.net_revenue) / a.net_revenue) * 100, 2) AS net_revenue_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct,
  a.total_tips AS tips_2024,
  b.total_tips AS tips_2025,
  ROUND(((b.total_tips - a.total_tips) / a.total_tips) * 100, 2) AS tips_growth_pct,
  a.total_driver_earnings AS driver_earnings_2024,
  b.total_driver_earnings AS driver_earnings_2025,
  ROUND(((b.total_driver_earnings - a.total_driver_earnings) / a.total_driver_earnings) * 100, 2) AS driver_earnings_growth_pct
FROM uber_do_2024 AS a
CROSS JOIN uber_do_2025 AS b;


-- Lyft Manhattan pickup revenue YoY
WITH lyft_pu_2024 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_pu_2025 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS gross_bookings_growth_pct,
  a.net_revenue AS net_revenue_2024,
  b.net_revenue AS net_revenue_2025,
  ROUND(((b.net_revenue - a.net_revenue) / a.net_revenue) * 100, 2) AS net_revenue_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct,
  a.total_tips AS tips_2024,
  b.total_tips AS tips_2025,
  ROUND(((b.total_tips - a.total_tips) / a.total_tips) * 100, 2) AS tips_growth_pct,
  a.total_driver_earnings AS driver_earnings_2024,
  b.total_driver_earnings AS driver_earnings_2025,
  ROUND(((b.total_driver_earnings - a.total_driver_earnings) / a.total_driver_earnings) * 100, 2) AS driver_earnings_growth_pct
FROM lyft_pu_2024 AS a
CROSS JOIN lyft_pu_2025 AS b;


-- Lyft Manhattan dropoff revenue YoY
WITH lyft_do_2024 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_do_2025 AS (
  SELECT
    ROUND(SUM(r.base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue,
    ROUND(SUM(r.driver_pay), 2) AS total_driver_pay,
    ROUND(SUM(r.tips), 2) AS total_tips,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS gross_bookings_growth_pct,
  a.net_revenue AS net_revenue_2024,
  b.net_revenue AS net_revenue_2025,
  ROUND(((b.net_revenue - a.net_revenue) / a.net_revenue) * 100, 2) AS net_revenue_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct,
  a.total_tips AS tips_2024,
  b.total_tips AS tips_2025,
  ROUND(((b.total_tips - a.total_tips) / a.total_tips) * 100, 2) AS tips_growth_pct,
  a.total_driver_earnings AS driver_earnings_2024,
  b.total_driver_earnings AS driver_earnings_2025,
  ROUND(((b.total_driver_earnings - a.total_driver_earnings) / a.total_driver_earnings) * 100, 2) AS driver_earnings_growth_pct
FROM lyft_do_2024 AS a
CROSS JOIN lyft_do_2025 AS b;


-- Uber citywide avg fare per trip
WITH uber_2024 AS (
  SELECT
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
),
uber_2025 AS (
  SELECT
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
)
SELECT
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.avg_driver_pay AS avg_driver_pay_2024,
  b.avg_driver_pay AS avg_driver_pay_2025,
  ROUND(((b.avg_driver_pay - a.avg_driver_pay) / a.avg_driver_pay) * 100, 2) AS avg_driver_pay_growth_pct,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM uber_2024 AS a
CROSS JOIN uber_2025 AS b;


-- Lyft citywide avg fare per trip
WITH lyft_2024 AS (
  SELECT
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
),
lyft_2025 AS (
  SELECT
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
)
SELECT
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.avg_driver_pay AS avg_driver_pay_2024,
  b.avg_driver_pay AS avg_driver_pay_2025,
  ROUND(((b.avg_driver_pay - a.avg_driver_pay) / a.avg_driver_pay) * 100, 2) AS avg_driver_pay_growth_pct,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM lyft_2024 AS a
CROSS JOIN lyft_2025 AS b;


-- Uber Manhattan pickup avg fare YoY
WITH uber_pu_2024 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_pu_2025 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.avg_driver_pay AS avg_driver_pay_2024,
  b.avg_driver_pay AS avg_driver_pay_2025,
  ROUND(((b.avg_driver_pay - a.avg_driver_pay) / a.avg_driver_pay) * 100, 2) AS avg_driver_pay_growth_pct,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM uber_pu_2024 AS a
CROSS JOIN uber_pu_2025 AS b;


-- Uber Manhattan dropoff avg fare YoY
WITH uber_do_2024 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_do_2025 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.avg_driver_pay AS avg_driver_pay_2024,
  b.avg_driver_pay AS avg_driver_pay_2025,
  ROUND(((b.avg_driver_pay - a.avg_driver_pay) / a.avg_driver_pay) * 100, 2) AS avg_driver_pay_growth_pct,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM uber_do_2024 AS a
CROSS JOIN uber_do_2025 AS b;


-- Lyft Manhattan pickup avg fare YoY
WITH lyft_pu_2024 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_pu_2025 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.avg_driver_pay AS avg_driver_pay_2024,
  b.avg_driver_pay AS avg_driver_pay_2025,
  ROUND(((b.avg_driver_pay - a.avg_driver_pay) / a.avg_driver_pay) * 100, 2) AS avg_driver_pay_growth_pct,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM lyft_pu_2024 AS a
CROSS JOIN lyft_pu_2025 AS b;


-- Lyft Manhattan dropoff avg fare YoY
WITH lyft_do_2024 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_do_2025 AS (
  SELECT
    ROUND(AVG(r.base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(r.driver_pay), 2) AS avg_driver_pay,
    ROUND(AVG(r.tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.avg_driver_pay AS avg_driver_pay_2024,
  b.avg_driver_pay AS avg_driver_pay_2025,
  ROUND(((b.avg_driver_pay - a.avg_driver_pay) / a.avg_driver_pay) * 100, 2) AS avg_driver_pay_growth_pct,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM lyft_do_2024 AS a
CROSS JOIN lyft_do_2025 AS b;


-- Congestion fee burden by company, 2025 only
SELECT
  company,
  ROUND(SUM(cbd_congestion_fee), 2) AS total_congestion_fees,
  ROUND(AVG(cbd_congestion_fee), 2) AS avg_fee_per_trip,
  COUNT(*) AS trips_charged
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
WHERE company IN ('Uber', 'Lyft')
  AND cbd_congestion_fee > 0
GROUP BY company;



-- LAYER 3: BEHAVIORAL PATTERNS


-- Uber hourly trip patterns, both years
WITH uber_2024 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
  GROUP BY hour_of_day
),
uber_2025 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
  GROUP BY hour_of_day
)
SELECT
  a.hour_of_day,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM uber_2024 AS a
JOIN uber_2025 AS b USING(hour_of_day)
ORDER BY hour_of_day;


-- Lyft hourly trip patterns, both years
WITH lyft_2024 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
  GROUP BY hour_of_day
),
lyft_2025 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
  GROUP BY hour_of_day
)
SELECT
  a.hour_of_day,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM lyft_2024 AS a
JOIN lyft_2025 AS b USING(hour_of_day)
ORDER BY hour_of_day;


-- Uber day of week growth YoY
WITH uber_2024 AS (
  SELECT
    FORMAT_TIMESTAMP('%A', pickup_datetime) AS day_of_week,
    EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_num,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
  GROUP BY day_of_week, day_num
),
uber_2025 AS (
  SELECT
    FORMAT_TIMESTAMP('%A', pickup_datetime) AS day_of_week,
    EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_num,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
  GROUP BY day_of_week, day_num
)
SELECT
  a.day_of_week,
  a.day_num,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM uber_2024 AS a
JOIN uber_2025 AS b USING(day_of_week, day_num)
ORDER BY day_num;


-- Lyft day of week growth YoY
WITH lyft_2024 AS (
  SELECT
    FORMAT_TIMESTAMP('%A', pickup_datetime) AS day_of_week,
    EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_num,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
  GROUP BY day_of_week, day_num
),
lyft_2025 AS (
  SELECT
    FORMAT_TIMESTAMP('%A', pickup_datetime) AS day_of_week,
    EXTRACT(DAYOFWEEK FROM pickup_datetime) AS day_num,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
  GROUP BY day_of_week, day_num
)
SELECT
  a.day_of_week,
  a.day_num,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM lyft_2024 AS a
JOIN lyft_2025 AS b USING(day_of_week, day_num)
ORDER BY day_num;


-- Uber borough breakdown, pickups, YoY growth
WITH uber_pu_2024 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
  GROUP BY t.borough
),
uber_pu_2025 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
  GROUP BY t.borough
)
SELECT
  a.borough,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM uber_pu_2024 AS a
JOIN uber_pu_2025 AS b USING(borough)
ORDER BY growth_pct DESC;


-- Uber borough breakdown, dropoffs, YoY growth
WITH uber_do_2024 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
  GROUP BY t.borough
),
uber_do_2025 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
  GROUP BY t.borough
)
SELECT
  a.borough,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM uber_do_2024 AS a
JOIN uber_do_2025 AS b USING(borough)
ORDER BY growth_pct DESC;


-- Lyft borough breakdown, pickups, YoY growth
WITH lyft_pu_2024 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
  GROUP BY t.borough
),
lyft_pu_2025 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
  GROUP BY t.borough
)
SELECT
  a.borough,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM lyft_pu_2024 AS a
JOIN lyft_pu_2025 AS b USING(borough)
ORDER BY growth_pct DESC;


-- Lyft borough breakdown, dropoffs, YoY growth
WITH lyft_do_2024 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
  GROUP BY t.borough
),
lyft_do_2025 AS (
  SELECT
    t.borough,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
  GROUP BY t.borough
)
SELECT
  a.borough,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM lyft_do_2024 AS a
JOIN lyft_do_2025 AS b USING(borough)
ORDER BY growth_pct DESC;


-- Shared ride behavior by company, both years
WITH shared_2024 AS (
  SELECT
    company,
    COUNTIF(shared_request_flag = 'Y') AS shared_requests,
    COUNTIF(shared_match_flag = 'Y') AS shared_matches,
    COUNT(*) AS total_trips,
    ROUND(COUNTIF(shared_request_flag = 'Y') / COUNT(*) * 100, 2) AS shared_request_pct,
    ROUND(COUNTIF(shared_match_flag = 'Y') / NULLIF(COUNTIF(shared_request_flag = 'Y'), 0) * 100, 2) AS match_rate_pct
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company IN ('Uber', 'Lyft')
  GROUP BY company
),
shared_2025 AS (
  SELECT
    company,
    COUNTIF(shared_request_flag = 'Y') AS shared_requests,
    COUNTIF(shared_match_flag = 'Y') AS shared_matches,
    COUNT(*) AS total_trips,
    ROUND(COUNTIF(shared_request_flag = 'Y') / COUNT(*) * 100, 2) AS shared_request_pct,
    ROUND(COUNTIF(shared_match_flag = 'Y') / NULLIF(COUNTIF(shared_request_flag = 'Y'), 0) * 100, 2) AS match_rate_pct
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company IN ('Uber', 'Lyft')
  GROUP BY company
)
SELECT
  a.company,
  a.shared_request_pct AS shared_request_pct_2024,
  b.shared_request_pct AS shared_request_pct_2025,
  ROUND(b.shared_request_pct - a.shared_request_pct, 2) AS shared_request_pct_diff,
  a.match_rate_pct AS match_rate_pct_2024,
  b.match_rate_pct AS match_rate_pct_2025,
  ROUND(b.match_rate_pct - a.match_rate_pct, 2) AS match_rate_pct_diff
FROM shared_2024 AS a
JOIN shared_2025 AS b USING(company)
ORDER BY company;


-- Uber citywide avg trip distance and duration YoY
WITH uber_2024 AS (
  SELECT
    ROUND(AVG(trip_miles), 2) AS avg_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
),
uber_2025 AS (
  SELECT
    ROUND(AVG(trip_miles), 2) AS avg_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
)
SELECT
  a.avg_miles AS avg_miles_2024,
  b.avg_miles AS avg_miles_2025,
  ROUND(((b.avg_miles - a.avg_miles) / a.avg_miles) * 100, 2) AS miles_growth_pct,
  a.avg_minutes AS avg_minutes_2024,
  b.avg_minutes AS avg_minutes_2025,
  ROUND(((b.avg_minutes - a.avg_minutes) / a.avg_minutes) * 100, 2) AS minutes_growth_pct
FROM uber_2024 AS a
CROSS JOIN uber_2025 AS b;


-- Lyft citywide avg trip distance and duration YoY
WITH lyft_2024 AS (
  SELECT
    ROUND(AVG(trip_miles), 2) AS avg_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
),
lyft_2025 AS (
  SELECT
    ROUND(AVG(trip_miles), 2) AS avg_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
)
SELECT
  a.avg_miles AS avg_miles_2024,
  b.avg_miles AS avg_miles_2025,
  ROUND(((b.avg_miles - a.avg_miles) / a.avg_miles) * 100, 2) AS miles_growth_pct,
  a.avg_minutes AS avg_minutes_2024,
  b.avg_minutes AS avg_minutes_2025,
  ROUND(((b.avg_minutes - a.avg_minutes) / a.avg_minutes) * 100, 2) AS minutes_growth_pct
FROM lyft_2024 AS a
CROSS JOIN lyft_2025 AS b;


-- Uber Manhattan pickup avg trip distance and duration YoY
WITH uber_pu_2024 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_pu_2025 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_miles AS avg_miles_2024,
  b.avg_miles AS avg_miles_2025,
  ROUND(((b.avg_miles - a.avg_miles) / a.avg_miles) * 100, 2) AS miles_growth_pct,
  a.avg_minutes AS avg_minutes_2024,
  b.avg_minutes AS avg_minutes_2025,
  ROUND(((b.avg_minutes - a.avg_minutes) / a.avg_minutes) * 100, 2) AS minutes_growth_pct
FROM uber_pu_2024 AS a
CROSS JOIN uber_pu_2025 AS b;


-- Uber Manhattan dropoff avg trip distance and duration YoY
WITH uber_do_2024 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
),
uber_do_2025 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_miles AS avg_miles_2024,
  b.avg_miles AS avg_miles_2025,
  ROUND(((b.avg_miles - a.avg_miles) / a.avg_miles) * 100, 2) AS miles_growth_pct,
  a.avg_minutes AS avg_minutes_2024,
  b.avg_minutes AS avg_minutes_2025,
  ROUND(((b.avg_minutes - a.avg_minutes) / a.avg_minutes) * 100, 2) AS minutes_growth_pct
FROM uber_do_2024 AS a
CROSS JOIN uber_do_2025 AS b;


-- Lyft Manhattan pickup avg trip distance and duration YoY
WITH lyft_pu_2024 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_pu_2025 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_miles AS avg_miles_2024,
  b.avg_miles AS avg_miles_2025,
  ROUND(((b.avg_miles - a.avg_miles) / a.avg_miles) * 100, 2) AS miles_growth_pct,
  a.avg_minutes AS avg_minutes_2024,
  b.avg_minutes AS avg_minutes_2025,
  ROUND(((b.avg_minutes - a.avg_minutes) / a.avg_minutes) * 100, 2) AS minutes_growth_pct
FROM lyft_pu_2024 AS a
CROSS JOIN lyft_pu_2025 AS b;


-- Lyft Manhattan dropoff avg trip distance and duration YoY
WITH lyft_do_2024 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
),
lyft_do_2025 AS (
  SELECT
    ROUND(AVG(r.trip_miles), 2) AS avg_miles,
    ROUND(AVG(r.trip_time / 60), 2) AS avg_minutes
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
)
SELECT
  a.avg_miles AS avg_miles_2024,
  b.avg_miles AS avg_miles_2025,
  ROUND(((b.avg_miles - a.avg_miles) / a.avg_miles) * 100, 2) AS miles_growth_pct,
  a.avg_minutes AS avg_minutes_2024,
  b.avg_minutes AS avg_minutes_2025,
  ROUND(((b.avg_minutes - a.avg_minutes) / a.avg_minutes) * 100, 2) AS minutes_growth_pct
FROM lyft_do_2024 AS a
CROSS JOIN lyft_do_2025 AS b;


-- Uber monthly trip trend, both years
WITH uber_monthly_2024 AS (
  SELECT
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
  GROUP BY month
),
uber_monthly_2025 AS (
  SELECT
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
  GROUP BY month
)
SELECT
  a.month,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM uber_monthly_2024 AS a
JOIN uber_monthly_2025 AS b USING(month)
ORDER BY month;


-- Lyft monthly trip trend, both years
WITH lyft_monthly_2024 AS (
  SELECT
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
  GROUP BY month
),
lyft_monthly_2025 AS (
  SELECT
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
  GROUP BY month
)
SELECT
  a.month,
  a.total_trips AS trips_2024,
  b.total_trips AS trips_2025,
  (b.total_trips - a.total_trips) AS trip_diff,
  ROUND(((b.total_trips - a.total_trips) / a.total_trips) * 100, 2) AS growth_pct
FROM lyft_monthly_2024 AS a
JOIN lyft_monthly_2025 AS b USING(month)
ORDER BY month;


-- Uber airport trips, both years
WITH uber_airport_2024 AS (
  SELECT
    COUNT(*) AS airport_trips,
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(airport_fee), 2) AS avg_airport_fee
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
    AND airport_fee > 0
),
uber_airport_2025 AS (
  SELECT
    COUNT(*) AS airport_trips,
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(airport_fee), 2) AS avg_airport_fee
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
    AND airport_fee > 0
)
SELECT
  a.airport_trips AS airport_trips_2024,
  b.airport_trips AS airport_trips_2025,
  (b.airport_trips - a.airport_trips) AS trip_diff,
  ROUND(((b.airport_trips - a.airport_trips) / a.airport_trips) * 100, 2) AS trip_growth_pct,
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS bookings_growth_pct,
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct
FROM uber_airport_2024 AS a
CROSS JOIN uber_airport_2025 AS b;


-- Lyft airport trips, both years
WITH lyft_airport_2024 AS (
  SELECT
    COUNT(*) AS airport_trips,
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(airport_fee), 2) AS avg_airport_fee
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
    AND airport_fee > 0
),
lyft_airport_2025 AS (
  SELECT
    COUNT(*) AS airport_trips,
    ROUND(SUM(base_passenger_fare), 2) AS gross_bookings,
    ROUND(SUM(driver_pay), 2) AS total_driver_pay,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(airport_fee), 2) AS avg_airport_fee
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
    AND airport_fee > 0
)
SELECT
  a.airport_trips AS airport_trips_2024,
  b.airport_trips AS airport_trips_2025,
  (b.airport_trips - a.airport_trips) AS trip_diff,
  ROUND(((b.airport_trips - a.airport_trips) / a.airport_trips) * 100, 2) AS trip_growth_pct,
  a.gross_bookings AS gross_bookings_2024,
  b.gross_bookings AS gross_bookings_2025,
  ROUND(((b.gross_bookings - a.gross_bookings) / a.gross_bookings) * 100, 2) AS bookings_growth_pct,
  a.avg_fare AS avg_fare_2024,
  b.avg_fare AS avg_fare_2025,
  ROUND(((b.avg_fare - a.avg_fare) / a.avg_fare) * 100, 2) AS avg_fare_growth_pct,
  a.total_driver_pay AS driver_pay_2024,
  b.total_driver_pay AS driver_pay_2025,
  ROUND(((b.total_driver_pay - a.total_driver_pay) / a.total_driver_pay) * 100, 2) AS driver_pay_growth_pct
FROM lyft_airport_2024 AS a
CROSS JOIN lyft_airport_2025 AS b;


-- Uber citywide driver pay per mile, both years
WITH uber_2024 AS (
  SELECT
    ROUND(AVG(driver_pay / NULLIF(trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
    AND trip_miles > 0
),
uber_2025 AS (
  SELECT
    ROUND(AVG(driver_pay / NULLIF(trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
    AND trip_miles > 0
)
SELECT
  a.avg_pay_per_mile AS avg_pay_per_mile_2024,
  b.avg_pay_per_mile AS avg_pay_per_mile_2025,
  ROUND(((b.avg_pay_per_mile - a.avg_pay_per_mile) / a.avg_pay_per_mile) * 100, 2) AS growth_pct
FROM uber_2024 AS a
CROSS JOIN uber_2025 AS b;


-- Lyft citywide driver pay per mile, both years
WITH lyft_2024 AS (
  SELECT
    ROUND(AVG(driver_pay / NULLIF(trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
    AND trip_miles > 0
),
lyft_2025 AS (
  SELECT
    ROUND(AVG(driver_pay / NULLIF(trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
    AND trip_miles > 0
)
SELECT
  a.avg_pay_per_mile AS avg_pay_per_mile_2024,
  b.avg_pay_per_mile AS avg_pay_per_mile_2025,
  ROUND(((b.avg_pay_per_mile - a.avg_pay_per_mile) / a.avg_pay_per_mile) * 100, 2) AS growth_pct
FROM lyft_2024 AS a
CROSS JOIN lyft_2025 AS b;


-- Uber Manhattan pickup driver pay per mile YoY
WITH uber_pu_2024 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
),
uber_pu_2025 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
)
SELECT
  a.avg_pay_per_mile AS avg_pay_per_mile_2024,
  b.avg_pay_per_mile AS avg_pay_per_mile_2025,
  ROUND(((b.avg_pay_per_mile - a.avg_pay_per_mile) / a.avg_pay_per_mile) * 100, 2) AS growth_pct
FROM uber_pu_2024 AS a
CROSS JOIN uber_pu_2025 AS b;


-- Uber Manhattan dropoff driver pay per mile YoY
WITH uber_do_2024 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
),
uber_do_2025 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Uber'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
)
SELECT
  a.avg_pay_per_mile AS avg_pay_per_mile_2024,
  b.avg_pay_per_mile AS avg_pay_per_mile_2025,
  ROUND(((b.avg_pay_per_mile - a.avg_pay_per_mile) / a.avg_pay_per_mile) * 100, 2) AS growth_pct
FROM uber_do_2024 AS a
CROSS JOIN uber_do_2025 AS b;


-- Lyft Manhattan pickup driver pay per mile YoY
WITH lyft_pu_2024 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
),
lyft_pu_2025 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
)
SELECT
  a.avg_pay_per_mile AS avg_pay_per_mile_2024,
  b.avg_pay_per_mile AS avg_pay_per_mile_2025,
  ROUND(((b.avg_pay_per_mile - a.avg_pay_per_mile) / a.avg_pay_per_mile) * 100, 2) AS growth_pct
FROM lyft_pu_2024 AS a
CROSS JOIN lyft_pu_2025 AS b;


-- Lyft Manhattan dropoff driver pay per mile YoY
WITH lyft_do_2024 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
),
lyft_do_2025 AS (
  SELECT
    ROUND(AVG(r.driver_pay / NULLIF(r.trip_miles, 0)), 2) AS avg_pay_per_mile
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.DOLocationID = t.LocationID
  WHERE r.company = 'Lyft'
    AND t.borough = 'Manhattan'
    AND r.trip_miles > 0
)
SELECT
  a.avg_pay_per_mile AS avg_pay_per_mile_2024,
  b.avg_pay_per_mile AS avg_pay_per_mile_2025,
  ROUND(((b.avg_pay_per_mile - a.avg_pay_per_mile) / a.avg_pay_per_mile) * 100, 2) AS growth_pct
FROM lyft_do_2024 AS a
CROSS JOIN lyft_do_2025 AS b;


-- Peak hour congestion zone trips by company (6AM-11AM), 2025 only
SELECT
  company,
  EXTRACT(HOUR FROM pickup_datetime) AS hour_of_day,
  COUNT(*) AS congestion_zone_trips,
  ROUND(AVG(cbd_congestion_fee), 2) AS avg_fee,
  ROUND(AVG(driver_pay), 2) AS avg_driver_pay,
  ROUND(AVG(base_passenger_fare), 2) AS avg_fare
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
WHERE company IN ('Uber', 'Lyft')
  AND cbd_congestion_fee > 0
  AND EXTRACT(HOUR FROM pickup_datetime) BETWEEN 6 AND 11
GROUP BY company, hour_of_day
ORDER BY company, hour_of_day;


-- Uber tip rate, both years (citywide)
WITH uber_2024 AS (
  SELECT
    ROUND(AVG(tips / NULLIF(base_passenger_fare, 0)) * 100, 2) AS tip_rate_pct,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Uber'
    AND base_passenger_fare > 0
),
uber_2025 AS (
  SELECT
    ROUND(AVG(tips / NULLIF(base_passenger_fare, 0)) * 100, 2) AS tip_rate_pct,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Uber'
    AND base_passenger_fare > 0
)
SELECT
  a.tip_rate_pct AS tip_rate_pct_2024,
  b.tip_rate_pct AS tip_rate_pct_2025,
  ROUND(b.tip_rate_pct - a.tip_rate_pct, 2) AS tip_rate_diff,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM uber_2024 AS a
CROSS JOIN uber_2025 AS b;


-- Lyft tip rate, both years (citywide)
WITH lyft_2024 AS (
  SELECT
    ROUND(AVG(tips / NULLIF(base_passenger_fare, 0)) * 100, 2) AS tip_rate_pct,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE company = 'Lyft'
    AND base_passenger_fare > 0
),
lyft_2025 AS (
  SELECT
    ROUND(AVG(tips / NULLIF(base_passenger_fare, 0)) * 100, 2) AS tip_rate_pct,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE company = 'Lyft'
    AND base_passenger_fare > 0
)
SELECT
  a.tip_rate_pct AS tip_rate_pct_2024,
  b.tip_rate_pct AS tip_rate_pct_2025,
  ROUND(b.tip_rate_pct - a.tip_rate_pct, 2) AS tip_rate_diff,
  a.avg_tip AS avg_tip_2024,
  b.avg_tip AS avg_tip_2025,
  ROUND(((b.avg_tip - a.avg_tip) / a.avg_tip) * 100, 2) AS avg_tip_growth_pct
FROM lyft_2024 AS a
CROSS JOIN lyft_2025 AS b;


-- Uber congestion zone avg trip characteristics, 2025
SELECT
  company,
  ROUND(AVG(trip_miles), 2) AS avg_miles,
  ROUND(AVG(trip_time / 60), 2) AS avg_minutes,
  ROUND(AVG(driver_pay), 2) AS avg_driver_pay,
  ROUND(AVG(driver_pay / NULLIF(trip_miles, 0)), 2) AS avg_pay_per_mile,
  ROUND(AVG(driver_pay / NULLIF(trip_time / 60, 0)), 2) AS avg_pay_per_minute,
  COUNT(*) AS total_trips
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
WHERE company = 'Uber'
  AND cbd_congestion_fee > 0
  AND trip_miles > 0
  AND trip_time > 0
GROUP BY company;


-- Lyft congestion zone avg trip characteristics, 2025
SELECT
  company,
  ROUND(AVG(trip_miles), 2) AS avg_miles,
  ROUND(AVG(trip_time / 60), 2) AS avg_minutes,
  ROUND(AVG(driver_pay), 2) AS avg_driver_pay,
  ROUND(AVG(driver_pay / NULLIF(trip_miles, 0)), 2) AS avg_pay_per_mile,
  ROUND(AVG(driver_pay / NULLIF(trip_time / 60, 0)), 2) AS avg_pay_per_minute,
  COUNT(*) AS total_trips
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
WHERE company = 'Lyft'
  AND cbd_congestion_fee > 0
  AND trip_miles > 0
  AND trip_time > 0
GROUP BY company;