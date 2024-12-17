--1. Identify Peak Testing Days

SELECT 
    TestDate, 
    TotalTests, 
    PositiveTests, 
    AvgTestCost, 
    AvgProcessingTime
FROM vw_DailyTestSummary
WHERE TotalTests = (
    SELECT MAX(TotalTests) 
    FROM vw_DailyTestSummary
)
ORDER BY TestDate;


--2. Find Patients with the Most Tests
SELECT 
    PatientName, 
    DiseaseName, 
    TotalTests, 
    TestHistory
FROM vw_PatientTestHistory
ORDER BY TotalTests DESC
LIMIT 5;

--3. Best Performing Facilities (Lowest Processing Time)
SELECT 
    FacilityName, 
    TotalTests, 
    AvgProcessingTime, 
    TotalCosts, 
    UniquePatients
FROM vw_FacilityPerformanceMetrics
WHERE TotalTests > 100
ORDER BY AvgProcessingTime ASC
LIMIT 5;

--4. Top Diseases by Positive Rate
SELECT 
    TestDate, 
    DiseaseName, 
    PositiveRate, 
    TotalTests, 
    PositiveTests
FROM vw_DiseaseTrendAnalysis
WHERE PositiveRate > 50
ORDER BY PositiveRate DESC
LIMIT 10;

--5. Providers with the Highest Test Volume
SELECT 
    ProviderName, 
    TotalTests, 
    AvgProcessingTime, 
    TotalCosts
FROM vw_ProviderTestActivity
ORDER BY TotalTests DESC
LIMIT 5;

--6. Monthly Trends for a Specific Disease
SELECT 
    DATE_TRUNC('month', TestDate) AS TestMonth, 
    DiseaseName, 
    SUM(TotalTests) AS MonthlyTests, 
    SUM(PositiveTests) AS MonthlyPositiveTests, 
    AVG(PositiveRate) AS AvgPositiveRate
FROM vw_DiseaseTrendAnalysis
WHERE DiseaseName = 'Influenza'
GROUP BY TestMonth, DiseaseName
ORDER BY TestMonth;

