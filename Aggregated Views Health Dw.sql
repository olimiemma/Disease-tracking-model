-- Create aggregated views for common analyses

-- 1. View for Daily Test Summary
CREATE OR REPLACE VIEW vw_DailyTestSummary AS
SELECT 
    dd.FullDate AS TestDate, 
    COUNT(*) AS TotalTests, 
    COUNT(CASE WHEN ft.TestResult = 'Positive' THEN 1 END) AS PositiveTests, 
    AVG(ft.TestCost)::NUMERIC(10,2) AS AvgTestCost, 
    AVG(ft.ProcessingTimeMinutes)::NUMERIC(10,2) AS AvgProcessingTime
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimDate dd ON ft.DateKey = dd.DateKey
GROUP BY dd.FullDate
ORDER BY dd.FullDate;

-- 2. View for Patient Test History
CREATE OR REPLACE VIEW vw_PatientTestHistory AS
SELECT 
    dp.PatientKey,
    dp.FirstName || ' ' || dp.LastName AS PatientName, 
    dd.DiseaseName, 
    COUNT(*) AS TotalTests, 
    STRING_AGG(ft.TestResult || ' (' || dt.FullDate::DATE || ')', '; ') AS TestHistory
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimPatient dp ON ft.PatientKey = dp.PatientKey
JOIN disease_dw.DimDisease dd ON ft.DiseaseKey = dd.DiseaseKey
JOIN disease_dw.DimDate dt ON ft.DateKey = dt.DateKey
GROUP BY dp.PatientKey, dp.FirstName, dp.LastName, dd.DiseaseName;

-- 3. View for Facility Performance Metrics
CREATE OR REPLACE VIEW vw_FacilityPerformanceMetrics AS
SELECT 
    df.FacilityKey,
    df.FacilityName, 
    COUNT(*) AS TotalTests, 
    AVG(ft.ProcessingTimeMinutes)::NUMERIC(10,2) AS AvgProcessingTime, 
    SUM(ft.TestCost)::NUMERIC(10,2) AS TotalCosts, 
    COUNT(DISTINCT ft.PatientKey) AS UniquePatients
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimFacility df ON ft.FacilityKey = df.FacilityKey
GROUP BY df.FacilityKey, df.FacilityName;

-- 4. View for Disease Trend Analysis
CREATE OR REPLACE VIEW vw_DiseaseTrendAnalysis AS
SELECT 
    dd.FullDate AS TestDate, 
    ds.DiseaseName, 
    COUNT(*) AS TotalTests, 
    COUNT(CASE WHEN ft.TestResult = 'Positive' THEN 1 END) AS PositiveTests, 
    ROUND((COUNT(CASE WHEN ft.TestResult = 'Positive' THEN 1 END) * 100.0 / COUNT(*)), 2) AS PositiveRate
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimDate dd ON ft.DateKey = dd.DateKey
JOIN disease_dw.DimDisease ds ON ft.DiseaseKey = ds.DiseaseKey
GROUP BY dd.FullDate, ds.DiseaseNam
ORDER BY dd.FullDate, ds.DiseaseName;

-- 5. View for Provider Test Activity
CREATE OR REPLACE VIEW vw_ProviderTestActivity AS
SELECT 
    dp.ProviderKey, 
    dp.ProviderName, 
    COUNT(*) AS TotalTests, 
    AVG(ft.ProcessingTimeMinutes)::NUMERIC(10,2) AS AvgProcessingTime, 
    SUM(ft.TestCost)::NUMERIC(10,2) AS TotalCosts
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimProvider dp ON ft.ProviderKey = dp.ProviderKey
GROUP BY dp.ProviderKey, dp.ProviderName;

-- End of Views Creation
