-- Populate FactTests
INSERT INTO disease_dw.FactTests (
    PatientKey, DiseaseKey, LocationKey, DateKey,
    ProviderKey, FacilityKey, TestType, Result,
    TestCost
)
SELECT 
    dp.PatientKey,
    dd.DiseaseKey,
    dl.LocationKey,
    TO_CHAR(dt.TestDate, 'YYYYMMDD')::INT AS DateKey,
    dpr.ProviderKey,
    df.FacilityKey,
    dt.TestType,
    dt.Result,
    RANDOM() * 1000 AS TestCost  -- Example cost calculation
FROM public.Disease_Test dt
JOIN disease_dw.DimPatient dp ON dt.PatientID = dp.PatientID AND dp.IsCurrent = TRUE
JOIN disease_dw.DimDisease dd ON dt.DiseaseID = dd.DiseaseID AND dd.IsCurrent = TRUE
JOIN disease_dw.DimLocation dl ON dt.FacilityID = dl.RegionID AND dl.IsCurrent = TRUE
JOIN disease_dw.DimProvider dpr ON dt.ProviderID = dpr.ProviderID AND dpr.IsCurrent = TRUE
JOIN disease_dw.DimFacility df ON dt.FacilityID = df.FacilityID AND df.IsCurrent = TRUE;

-- Populate FactOutbreaks
INSERT INTO disease_dw.FactOutbreaks (
    DiseaseKey, LocationKey, StartDateKey, EndDateKey,
    TotalCases, MortalityRate, EconomicImpact
)
SELECT 
    dd.DiseaseKey,
    dl.LocationKey,
    TO_CHAR(dout.StartDate, 'YYYYMMDD')::INT AS StartDateKey,
    TO_CHAR(dout.EndDate, 'YYYYMMDD')::INT AS EndDateKey,
    dout.TotalCases,
    RANDOM() * 5 AS MortalityRate,  -- Example mortality rate
    dout.TotalCases * 1000 AS EconomicImpact  -- Example economic impact calculation
FROM public.Disease_Outbreak dout  -- Changed 'do' to 'dout'
JOIN disease_dw.DimDisease dd ON dout.DiseaseID = dd.DiseaseID AND dd.IsCurrent = TRUE
JOIN disease_dw.DimLocation dl ON dout.RegionID = dl.RegionID AND dl.IsCurrent = TRUE;

-- 2. Populate FactTests
INSERT INTO disease_dw.FactTests (
    PatientKey, DiseaseKey, LocationKey, DateKey,
    ProviderKey, FacilityKey, TestType, Result,
    TestCost
)
SELECT 
    dp.PatientKey,
    dd.DiseaseKey,
    dl.LocationKey,
    TO_CHAR(dt.TestDate, 'YYYYMMDD')::INT AS DateKey,
    dpr.ProviderKey,
    df.FacilityKey,
    dt.TestType,
    dt.Result,
    RANDOM() * 1000 AS TestCost  -- Example cost calculation
FROM public.Disease_Test dt
JOIN disease_dw.DimPatient dp ON dt.PatientID = dp.PatientID AND dp.IsCurrent = TRUE
JOIN disease_dw.DimDisease dd ON dt.DiseaseID = dd.DiseaseID AND dd.IsCurrent = TRUE
JOIN disease_dw.DimLocation dl ON dt.FacilityID = dl.RegionID AND dl.IsCurrent = TRUE
JOIN disease_dw.DimProvider dpr ON dt.ProviderID = dpr.ProviderID AND dpr.IsCurrent = TRUE
JOIN disease_dw.DimFacility df ON dt.FacilityID = df.FacilityID AND df.IsCurrent = TRUE;