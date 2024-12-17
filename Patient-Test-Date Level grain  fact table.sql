CREATE TABLE disease_dw.FactPatientTests (
    -- Surrogate Key
    PatientTestKey SERIAL PRIMARY KEY,
    
    -- Dimension Keys
    PatientKey INTEGER REFERENCES disease_dw.DimPatient(PatientKey),
    DiseaseKey INTEGER REFERENCES disease_dw.DimDisease(DiseaseKey),
    DateKey INTEGER REFERENCES disease_dw.DimDate(DateKey),
    FacilityKey INTEGER REFERENCES disease_dw.DimFacility(FacilityKey),
    ProviderKey INTEGER REFERENCES disease_dw.DimProvider(ProviderKey),
    
    -- Facts (Measures)
    TestResult VARCHAR(20),
    TestValue DECIMAL(10,2),        -- For quantitative test results
    ProcessingTimeMinutes INTEGER,
    TestCost DECIMAL(10,2),
    
    -- Additional context
    TestType VARCHAR(100),
    IsCritical BOOLEAN,
    BatchNumber VARCHAR(50),
    
    -- Timestamps for auditing
    ETLLoadID INTEGER,
    ETLLoadDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add appropriate indexes
CREATE INDEX idx_fact_patient_date ON disease_dw.FactPatientTests(DateKey);
CREATE INDEX idx_fact_patient_disease ON disease_dw.FactPatientTests(DiseaseKey);
CREATE INDEX idx_fact_patient_facility ON disease_dw.FactPatientTests(FacilityKey);