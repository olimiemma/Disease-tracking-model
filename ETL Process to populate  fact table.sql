INSERT INTO disease_dw.FactPatientTests (
    PatientKey, 
    DiseaseKey,
    DateKey,
    FacilityKey,
    ProviderKey,
    TestResult,
    TestValue,
    ProcessingTimeMinutes,
    TestCost,
    TestType,
    IsCritical,
    BatchNumber
)
SELECT 
    dp.PatientKey,
    dd.DiseaseKey,
    TO_CHAR(dt.TestDate, 'YYYYMMDD')::INTEGER as DateKey,
    df.FacilityKey,
    dpr.ProviderKey,
    dt.Result,
    CASE 
        WHEN dt.TestType = 'PCR' THEN RANDOM() * 40 -- Example CT value
        ELSE NULL 
    END as TestValue,
    FLOOR(RANDOM() * 120)::INTEGER as ProcessingTimeMinutes, -- Example processing time
    RANDOM() * 1000 as TestCost,
    dt.TestType,
    CASE 
        WHEN dt.Result = 'Positive' AND dt.TestType = 'PCR' THEN TRUE
        ELSE FALSE 
    END as IsCritical,
    'BATCH-' || TO_CHAR(dt.TestDate, 'YYYYMMDD') as BatchNumber
FROM public.Disease_Test dt
JOIN disease_dw.DimPatient dp ON dt.PatientID = dp.PatientID AND dp.IsCurrent = TRUE
JOIN disease_dw.DimDisease dd ON dt.DiseaseID = dd.DiseaseID AND dd.IsCurrent = TRUE
JOIN disease_dw.DimFacility df ON dt.FacilityID = df.FacilityID AND df.IsCurrent = TRUE
JOIN disease_dw.DimProvider dpr ON dt.ProviderID = dpr.ProviderID AND dpr.IsCurrent = TRUE;