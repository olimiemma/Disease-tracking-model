-- Populate FactCases
INSERT INTO disease_dw.FactCases (
    PatientKey,
    DiseaseKey,
    LocationKey,
    DateKey,
    ProviderKey,
    FacilityKey,
    Severity,
    LengthOfStay,
    Outcome,
    TreatmentCost
)
SELECT 
    dp.PatientKey,
    dd.DiseaseKey,
    dl.LocationKey,
    to_char(dt.TestDate, 'YYYYMMDD')::integer AS DateKey,
    dpr.ProviderKey,
    df.FacilityKey,
    CASE 
        WHEN dt.Result = 'Positive' THEN 'Moderate'
        WHEN dt.Result = 'Severe Positive' THEN 'Severe'
        ELSE 'Mild'
    END AS Severity,
    ceil(random() * 14)::integer AS LengthOfStay,  -- Random stay between 1-14 days
    CASE 
        WHEN dt.Result = 'Negative' THEN 'Recovered'
        WHEN dt.Result = 'Severe Positive' THEN 'Critical'
        ELSE 'Under Treatment'
    END AS Outcome,
    (random() * 10000)::numeric(10,2) AS TreatmentCost
FROM public.Disease_Test dt
JOIN disease_dw.DimPatient dp 
    ON dt.PatientID = dp.PatientID 
    AND dp.IsCurrent = true
JOIN disease_dw.DimDisease dd 
    ON dt.DiseaseID = dd.DiseaseID 
    AND dd.IsCurrent = true
JOIN disease_dw.DimLocation dl 
    ON dt.FacilityID = dl.RegionID 
    AND dl.IsCurrent = true
JOIN disease_dw.DimProvider dpr 
    ON dt.ProviderID = dpr.ProviderID 
    AND dpr.IsCurrent = true
JOIN disease_dw.DimFacility df 
    ON dt.FacilityID = df.FacilityID 
    AND df.IsCurrent = true;

-- Populate FactInventory
INSERT INTO disease_dw.FactInventory (
    FacilityKey,
    DateKey,
    ResourceType,
    Quantity,
    Value,
    DaysOfSupply
)
SELECT 
    df.FacilityKey,
    to_char(dt.TestDate, 'YYYYMMDD')::integer AS DateKey,
    'Test Kits' AS ResourceType,
    (COUNT(*) * 100)::integer AS Quantity,
    (COUNT(*) * 100 * 50)::numeric(10,2) AS Value,
    30::integer AS DaysOfSupply
FROM public.Disease_Test dt
JOIN disease_dw.DimFacility df 
    ON dt.FacilityID = df.FacilityID 
    AND df.IsCurrent = true
GROUP BY 
    df.FacilityKey,
    to_char(dt.TestDate, 'YYYYMMDD')::integer;