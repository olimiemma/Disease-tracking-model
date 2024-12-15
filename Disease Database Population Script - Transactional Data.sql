-- Generate 1000 Patients
INSERT INTO Patient (FirstName, LastName, DateOfBirth, Gender, BloodType, RegionID, ContactNumber, EmailAddress, MedicalHistory)
SELECT 
    'FirstName' || n,
    'LastName' || n,
    '1940-01-01'::date + (random() * 29200)::integer,
    CASE WHEN random() < 0.5 THEN 'Male' ELSE 'Female' END,
    (ARRAY['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'])[floor(random() * 8 + 1)],
    floor(random() * 5 + 1),
    '+1' || LPAD(floor(random() * 9999999999)::text, 10, '0'),
    'patient' || n || '@email.com',
    CASE WHEN random() < 0.3 THEN 'Hypertension, Diabetes' 
         WHEN random() < 0.6 THEN 'Asthma' 
         ELSE 'None' END
FROM generate_series(1, 1000) n;

-- Generate Disease Tests (5000 tests across different diseases and patients)
-- Generate Disease Tests (5000 tests across different diseases and patients)
INSERT INTO Disease_Test (PatientID, DiseaseID, TestDate, TestType, Result, FacilityID, ProviderID)
SELECT 
    floor(random() * 1000 + 1),  -- PatientID
    floor(random() * 5 + 1),     -- DiseaseID
    '2023-01-01'::date + (random() * 364)::integer, -- TestDate
    CASE 
        WHEN random() < 0.5 THEN 'PCR'
        WHEN random() < 0.8 THEN 'Rapid Antigen'
        ELSE 'Antibody'
    END,
    CASE 
        WHEN random() < 0.2 THEN 'Positive'
        WHEN random() < 0.9 THEN 'Negative'
        ELSE 'Inconclusive'
    END,
    floor(random() * 8 + 1),     -- FacilityID
    21 + floor(random() * 20)    -- ProviderID (21-40)
FROM generate_series(1, 5000) n;

-- Generate Case Records for positive tests
INSERT INTO Case_Record (PatientID, DiseaseID, VariantID, DiagnosisDate, Severity, Symptoms, Treatment, Outcome, DischargeDate, FacilityID, ProviderID)
SELECT 
    t.PatientID,
    t.DiseaseID,
    CASE WHEN t.DiseaseID = 1 THEN floor(random() * 3 + 1) ELSE NULL END,
    t.TestDate,
    CASE 
        WHEN random() < 0.6 THEN 'Mild'
        WHEN random() < 0.9 THEN 'Moderate'
        ELSE 'Severe'
    END,
    'Reported symptoms based on disease',
    'Standard protocol followed',
    CASE 
        WHEN random() < 0.95 THEN 'Recovered'
        ELSE 'Deceased'
    END,
    t.TestDate + (floor(random() * 30 + 5)||' days')::interval,
    t.FacilityID,
    t.ProviderID
FROM Disease_Test t
WHERE t.Result = 'Positive';

-- Generate Disease Outbreaks
INSERT INTO Disease_Outbreak (DiseaseID, RegionID, StartDate, EndDate, TotalCases, Status, ContainmentMeasures)
SELECT 
    floor(random() * 5 + 1),
    floor(random() * 5 + 1),
    start_date,
    start_date + (floor(random() * 90 + 30)||' days')::interval,
    floor(random() * 1000 + 100),
    CASE 
        WHEN random() < 0.7 THEN 'Contained'
        ELSE 'Active'
    END,
    'Social distancing, Contact tracing, Quarantine measures'
FROM (
    SELECT '2023-01-01'::date + (n * 30 || ' days')::interval as start_date
    FROM generate_series(0, 11) n
) dates;