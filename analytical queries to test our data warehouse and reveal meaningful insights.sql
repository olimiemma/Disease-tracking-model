-- 1. Disease Test Effectiveness by Region
SELECT 
    dl.Country,
    dl.State,
    dd.DiseaseName,
    COUNT(*) as TotalTests,
    COUNT(CASE WHEN ft.Result = 'Positive' THEN 1 END) as PositiveTests,
    ROUND(COUNT(CASE WHEN ft.Result = 'Positive' THEN 1 END) * 100.0 / COUNT(*), 2) as PositivityRate,
    AVG(ft.TestCost)::numeric(10,2) as AvgTestCost
FROM disease_dw.FactTests ft
JOIN disease_dw.DimLocation dl ON ft.LocationKey = dl.LocationKey
JOIN disease_dw.DimDisease dd ON ft.DiseaseKey = dd.DiseaseKey
GROUP BY dl.Country, dl.State, dd.DiseaseName
ORDER BY TotalTests DESC;

-- 2. Outbreak Analysis
SELECT 
    dd.DiseaseName,
    dl.Country,
    dl.State,
    SUM(fo.TotalCases) as TotalCases,
    AVG(fo.MortalityRate)::numeric(10,2) as AvgMortalityRate,
    SUM(fo.EconomicImpact)::numeric(10,2) as TotalEconomicImpact
FROM disease_dw.FactOutbreaks fo
JOIN disease_dw.DimLocation dl ON fo.LocationKey = dl.LocationKey
JOIN disease_dw.DimDisease dd ON fo.DiseaseKey = dd.DiseaseKey
GROUP BY dd.DiseaseName, dl.Country, dl.State
ORDER BY TotalCases DESC;

-- 3. Testing Trends Over Time
SELECT 
    dd.DiseaseName,
    dt.MonthName,
    dt.Year,
    COUNT(*) as TestsPerformed,
    COUNT(CASE WHEN ft.Result = 'Positive' THEN 1 END) as PositiveCases,
    AVG(ft.TestCost)::numeric(10,2) as AvgTestCost
FROM disease_dw.FactTests ft
JOIN disease_dw.DimDate dt ON ft.DateKey = dt.DateKey
JOIN disease_dw.DimDisease dd ON ft.DiseaseKey = dd.DiseaseKey
GROUP BY dd.DiseaseName, dt.MonthName, dt.Year, dt.Month
ORDER BY dt.Year, dt.Month;

-- 4. Top Testing Facilities
SELECT 
    df.FacilityName,
    dl.State,
    COUNT(*) as TotalTests,
    COUNT(DISTINCT ft.PatientKey) as UniquePatients,
    SUM(ft.TestCost)::numeric(10,2) as TotalTestCost,
    AVG(ft.TestCost)::numeric(10,2) as AvgTestCost
FROM disease_dw.FactTests ft
JOIN disease_dw.DimFacility df ON ft.FacilityKey = df.FacilityKey
JOIN disease_dw.DimLocation dl ON ft.LocationKey = dl.LocationKey
GROUP BY df.FacilityName, dl.State
ORDER BY TotalTests DESC;

-- 5. Disease Impact by Location Population Size
SELECT 
    dd.DiseaseName,
    dl.State,
    dl.Population,
    COUNT(DISTINCT fo.OutbreakKey) as NumberOfOutbreaks,
    SUM(fo.TotalCases) as TotalCases,
    (SUM(fo.TotalCases)::decimal / NULLIF(dl.Population, 0) * 100)::numeric(10,2) as InfectionRate,
    AVG(fo.MortalityRate)::numeric(10,2) as AvgMortalityRate
FROM disease_dw.FactOutbreaks fo
JOIN disease_dw.DimLocation dl ON fo.LocationKey = dl.LocationKey
JOIN disease_dw.DimDisease dd ON fo.DiseaseKey = dd.DiseaseKey
WHERE dl.Population > 0
GROUP BY dd.DiseaseName, dl.State, dl.Population
ORDER BY InfectionRate DESC;

-- 6. Cross Analysis: Tests vs Outbreaks
WITH TestSummary AS (
    SELECT 
        dl.State,
        dd.DiseaseName,
        COUNT(*) as TotalTests,
        COUNT(CASE WHEN ft.Result = 'Positive' THEN 1 END) as PositiveCases
    FROM disease_dw.FactTests ft
    JOIN disease_dw.DimLocation dl ON ft.LocationKey = dl.LocationKey
    JOIN disease_dw.DimDisease dd ON ft.DiseaseKey = dd.DiseaseKey
    GROUP BY dl.State, dd.DiseaseName
)
SELECT 
    ts.State,
    ts.DiseaseName,
    ts.TotalTests,
    ts.PositiveCases,
    COUNT(DISTINCT fo.OutbreakKey) as NumberOfOutbreaks,
    SUM(fo.TotalCases) as TotalOutbreakCases
FROM TestSummary ts
JOIN disease_dw.DimLocation dl ON dl.State = ts.State
JOIN disease_dw.DimDisease dd ON dd.DiseaseName = ts.DiseaseName
JOIN disease_dw.FactOutbreaks fo ON fo.LocationKey = dl.LocationKey AND fo.DiseaseKey = dd.DiseaseKey
GROUP BY ts.State, ts.DiseaseName, ts.TotalTests, ts.PositiveCases
ORDER BY TotalOutbreakCases DESC;