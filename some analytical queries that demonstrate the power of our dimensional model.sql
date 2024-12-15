

-- First, let's check our tables
SELECT * FROM information_schema.tables 
WHERE table_schema = 'disease_dw';

-- Then set our search path
SET search_path TO disease_dw, public;

-- 1. Disease Spread Analysis
SELECT 
    d.DiseaseName,
    l.Country,
    l.State,
    dt.MonthName,
    COUNT(fc.CaseKey) as TotalCases,
    AVG(fc.LengthOfStay) as AvgLengthOfStay,
    SUM(fc.TreatmentCost) as TotalTreatmentCost
FROM FactCases fc
JOIN DimDisease d ON fc.DiseaseKey = d.DiseaseKey
JOIN DimLocation l ON fc.LocationKey = l.LocationKey
JOIN DimDate dt ON fc.DateKey = dt.DateKey
WHERE d.IsCurrent = true
GROUP BY d.DiseaseName, l.Country, l.State, dt.MonthName
ORDER BY TotalCases DESC;

-- 2. Testing Effectiveness Analysis
SELECT 
    d.DiseaseName,
    f.FacilityName,
    ft.TestType,
    COUNT(*) as TotalTests,
    SUM(CASE WHEN ft.Result = 'Positive' THEN 1 ELSE 0 END) as PositiveTests,
    ROUND(SUM(CASE WHEN ft.Result = 'Positive' THEN 1 ELSE 0 END)::decimal / 
          COUNT(*)::decimal * 100, 2) as PositivityRate,
    AVG(ft.TestCost) as AvgTestCost
FROM FactTests ft
JOIN DimDisease d ON ft.DiseaseKey = d.DiseaseKey
JOIN DimFacility f ON ft.FacilityKey = f.FacilityKey
GROUP BY d.DiseaseName, f.FacilityName, ft.TestType
HAVING COUNT(*) > 100
ORDER BY PositivityRate DESC;

-- 3. Provider Performance Dashboard
SELECT 
    p.FullName as Provider,
    p.Specialty,
    COUNT(DISTINCT fc.PatientKey) as TotalPatients,
    AVG(fc.LengthOfStay) as AvgPatientStay,
    COUNT(CASE WHEN fc.Outcome = 'Recovered' THEN 1 END) as Recoveries,
    ROUND(COUNT(CASE WHEN fc.Outcome = 'Recovered' THEN 1 END)::decimal / 
          COUNT(*)::decimal * 100, 2) as RecoveryRate
FROM FactCases fc
JOIN DimProvider p ON fc.ProviderKey = p.ProviderKey
WHERE p.IsActive = true
GROUP BY p.FullName, p.Specialty
ORDER BY TotalPatients DESC;

-- 4. Resource Utilization Trends
SELECT 
    f.FacilityName,
    fi.ResourceType,
    dt.MonthName,
    AVG(fi.Quantity) as AvgQuantity,
    MIN(fi.Quantity) as MinQuantity,
    MAX(fi.Quantity) as MaxQuantity,
    AVG(fi.DaysOfSupply) as AvgDaysOfSupply
FROM FactInventory fi
JOIN DimFacility f ON fi.FacilityKey = f.FacilityKey
JOIN DimDate dt ON fi.DateKey = dt.DateKey
GROUP BY f.FacilityName, fi.ResourceType, dt.MonthName
HAVING AVG(fi.DaysOfSupply) < 30
ORDER BY AvgDaysOfSupply;

-- 5. Outbreak Impact Analysis
SELECT 
    d.DiseaseName,
    l.Country,
    l.State,
    SUM(fo.TotalCases) as TotalCases,
    AVG(fo.MortalityRate) as AvgMortalityRate,
    SUM(fo.EconomicImpact) as TotalEconomicImpact,
    AVG(endDate.FullDate - startDate.FullDate) as AvgOutbreakDuration
FROM FactOutbreaks fo
JOIN DimDisease d ON fo.DiseaseKey = d.DiseaseKey
JOIN DimLocation l ON fo.LocationKey = l.LocationKey
JOIN DimDate startDate ON fo.StartDateKey = startDate.DateKey
JOIN DimDate endDate ON fo.EndDateKey = endDate.DateKey
GROUP BY d.DiseaseName, l.Country, l.State
ORDER BY TotalCases DESC;

-- 6. Patient Demographics Impact
SELECT 
    p.AgeGroup,
    p.Gender,
    d.DiseaseName,
    COUNT(*) as TotalCases,
    AVG(fc.LengthOfStay) as AvgLengthOfStay,
    COUNT(CASE WHEN fc.Severity = 'Severe' THEN 1 END) as SevereCases,
    ROUND(COUNT(CASE WHEN fc.Outcome = 'Recovered' THEN 1 END)::decimal / 
          COUNT(*)::decimal * 100, 2) as RecoveryRate
FROM FactCases fc
JOIN DimPatient p ON fc.PatientKey = p.PatientKey
JOIN DimDisease d ON fc.DiseaseKey = d.DiseaseKey
GROUP BY p.AgeGroup, p.Gender, d.DiseaseName
ORDER BY TotalCases DESC;