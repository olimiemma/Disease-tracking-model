-- Daily Test Analysis
SELECT 
    dd.Year,
    dd.MonthName,
    dd.DayOfWeek,
    COUNT(*) as TotalTests,
    COUNT(CASE WHEN ft.TestResult = 'Positive' THEN 1 END) as PositiveTests,
    AVG(ft.TestCost)::numeric(10,2) as AvgTestCost,
    AVG(ft.ProcessingTimeMinutes)::numeric(10,2) as AvgProcessingTime
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimDate dd ON ft.DateKey = dd.DateKey
GROUP BY dd.Year, dd.MonthName, dd.DayOfWeek
ORDER BY dd.Year, dd.MonthName;

-- Patient Testing History
SELECT 
    dp.FirstName || ' ' || dp.LastName as PatientName,
    dd.DiseaseName,
    COUNT(*) as TotalTests,
    STRING_AGG(ft.TestResult || ' (' || dt.FullDate::date || ')', '; ') as TestHistory
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimPatient dp ON ft.PatientKey = dp.PatientKey
JOIN disease_dw.DimDisease dd ON ft.DiseaseKey = dd.DiseaseKey
JOIN disease_dw.DimDate dt ON ft.DateKey = dt.DateKey
GROUP BY dp.PatientKey, dp.FirstName, dp.LastName, dd.DiseaseName;

-- Facility Performance Metrics
SELECT 
    df.FacilityName,
    COUNT(*) as TotalTests,
    AVG(ft.ProcessingTimeMinutes)::numeric(10,2) as AvgProcessingTime,
    SUM(ft.TestCost)::numeric(10,2) as TotalCosts,
    COUNT(DISTINCT ft.PatientKey) as UniquePatients
FROM disease_dw.FactPatientTests ft
JOIN disease_dw.DimFacility df ON ft.FacilityKey = df.FacilityKey
GROUP BY df.FacilityKey, df.FacilityName;