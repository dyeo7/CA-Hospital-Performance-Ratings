CREATE SCHEMA ca;
CREATE TABLE ca.perf (
_ID INT,
year INT,
county VARCHAR(50),
hospital VARCHAR(100),
OSHPDID VARCHAR(20),
system VARCHAR(100),
type_of_report VARCHAR(50),
performance_measure VARCHAR(100),
adverse_events FLOAT,
cases FLOAT,
risk_adjusted_rate FLOAT,
hospital_ratings VARCHAR(50),
latitude FLOAT,
longitude FLOAT
);
SELECT * FROM ca.perf;

-- Kaiser Foundation Hospital Analysis

--identify high-risk kaiser hospitals by adverse events
WITH kaiser_avg AS (SELECT AVG(adverse_events) AS "Overall Avg Kaiser Adverse Events"
FROM ca.perf
WHERE hospital LIKE 'Kaiser%'
),
highrisk_kaiser AS (SELECT hospital, AVG(adverse_events) AS "Avg Adverse Events"
FROM ca.perf
WHERE hospital LIKE 'Kaiser%'
GROUP BY hospital
)
SELECT hk.hospital, hk."Avg Adverse Events", ka."Overall Avg Kaiser Adverse Events"
FROM highrisk_kaiser hk
JOIN kaiser_avg ka ON 1=1
WHERE hk."Avg Adverse Events" > ka."Overall Avg Kaiser Adverse Events"
ORDER BY hk."Avg Adverse Events" DESC;

--identify high-risk kaiser hospitals by cases
WITH kaiser_avg AS (SELECT AVG(cases) AS "Overall Avg Cases"
FROM ca.perf
WHERE hospital LIKE 'Kaiser%'
),
cases_kaiser AS (SELECT hospital, AVG(cases) AS "Avg Cases"
FROM ca.perf
WHERE hospital LIKE 'Kaiser%'
GROUP BY hospital
)
SELECT ck.hospital, ck."Avg Cases", ka."Overall Avg Cases"
FROM cases_kaiser ck
JOIN kaiser_avg ka ON 1=1
WHERE ck."Avg Cases" > ka."Overall Avg Cases"
ORDER BY ck."Avg Cases" DESC;

-- Performance trends over 2017-22 LA County Kaiser hospitals (# of cases, adverse events by performance measures)
SELECT hospital, performance_measure,
SUM(CASE WHEN year = '2017' THEN cases END) AS "2017 Total Cases",
SUM(CASE WHEN year = '2018' THEN cases END) AS "2018 Total Cases",
SUM(CASE WHEN year = '2019' THEN cases END) AS "2019 Total Cases",
SUM(CASE WHEN year = '2020' THEN cases END) AS "2020 Total Cases",
SUM(CASE WHEN year = '2021' THEN cases END) AS "2021 Total Cases",
SUM(CASE WHEN year = '2022' THEN cases END) AS "2022 Total Cases",
SUM(CASE WHEN year = '2017' THEN adverse_events END) AS "2017 Adverse Events",
SUM(CASE WHEN year = '2018' THEN adverse_events END) AS "2018 Adverse Events",
SUM(CASE WHEN year = '2019' THEN adverse_events END) AS "2019 Adverse Events",
SUM(CASE WHEN year = '2020' THEN adverse_events END) AS "2020 Adverse Events",
SUM(CASE WHEN year = '2021' THEN adverse_events END) AS "2021 Adverse Events",
SUM(CASE WHEN year = '2022' THEN adverse_events END) AS "2022 Adverse Events"
FROM ca.perf
WHERE county = 'Los Angeles' AND hospital LIKE 'Kaiser%'
GROUP BY hospital, performance_measure
ORDER BY hospital, performance_measure;

-- cte with ranking function of type of report by avg adverse events
-- imi
WITH k_imi AS (SELECT year, hospital, type_of_report, AVG(adverse_events) AS "Avg IMI Adverse Events", AVG(risk_adjusted_rate) AS "Avg Risk Rate", hospital_ratings,
RANK () OVER (PARTITION BY year ORDER BY AVG(adverse_events) DESC) AS rank
FROM ca.perf
WHERE hospital LIKE 'Kaiser%' AND type_of_report = 'IMI'
GROUP BY year, hospital, type_of_report, hospital_ratings
)
SELECT year, hospital, type_of_report, "Avg IMI Adverse Events",  "Avg Risk Rate", hospital_ratings
FROM k_imi
WHERE rank = 1
ORDER BY year DESC;

--psi
WITH k_psi AS (SELECT year, hospital, type_of_report, AVG(adverse_events) AS "Avg PSI Adverse Events", AVG(risk_adjusted_rate) AS "Avg Risk Rate", hospital_ratings,
RANK () OVER (PARTITION BY year ORDER BY AVG(adverse_events) DESC) AS rank
FROM ca.perf
WHERE hospital LIKE 'Kaiser%' AND type_of_report = 'PSI'
GROUP BY year, hospital, type_of_report, hospital_ratings
)
SELECT year, hospital, type_of_report, "Avg PSI Adverse Events", "Avg Risk Rate", hospital_ratings
FROM k_psi
WHERE rank = 1
ORDER BY year DESC;

--cabg
WITH k_cabg AS (SELECT year, hospital, type_of_report, AVG(adverse_events) AS "Avg CABG Adverse Events", AVG(risk_adjusted_rate) AS "Avg Risk Rate", hospital_ratings,
RANK () OVER (PARTITION BY year ORDER BY AVG(adverse_events) DESC) AS rank
FROM ca.perf
WHERE hospital LIKE 'Kaiser%' AND type_of_report = 'CABG'
GROUP BY year, hospital, type_of_report, hospital_ratings
)
SELECT year, hospital, type_of_report, "Avg CABG Adverse Events",  "Avg Risk Rate", hospital_ratings
FROM k_cabg
WHERE rank = 1
ORDER BY year DESC;
