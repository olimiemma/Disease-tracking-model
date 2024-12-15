-- Track new outbreak in a region
INSERT INTO Disease_Outbreak (DiseaseID, RegionID, StartDate, TotalCases, Status, ContainmentMeasures)
VALUES (1, 1, CURRENT_DATE, 100, 'Active', 'Social distancing and mask mandates');

-- Update outbreak status and cases
UPDATE Disease_Outbreak 
SET TotalCases = TotalCases + 50,
    ContainmentMeasures = ContainmentMeasures || ', Vaccination drives'
WHERE OutbreakID = 1;

-- Close an outbreak
UPDATE Disease_Outbreak 
SET Status = 'Contained',
    EndDate = CURRENT_DATE
WHERE OutbreakID = 1;




-- Register new case
INSERT INTO Case_Record (PatientID, DiseaseID, VariantID, DiagnosisDate, Severity, Symptoms)
VALUES (1, 1, 1, CURRENT_DATE, 'Moderate', 'Fever, Cough');

-- Update case severity
UPDATE Case_Record
SET Severity = 'Severe',
    Treatment = 'Hospitalization required'
WHERE CaseID = 1;

-- Record recovery
UPDATE Case_Record
SET Outcome = 'Recovered',
    DischargeDate = CURRENT_DATE
WHERE CaseID = 1;



-- Track resource usage
UPDATE Resource_Inventory
SET Quantity = Quantity - 10
WHERE FacilityID = 1 AND ResourceType = 'Ventilators';

-- Alert query for low resources
SELECT f.Name as Facility, ri.ResourceType, ri.Quantity, ri.MinimumThreshold
FROM Resource_Inventory ri
JOIN Healthcare_Facility f ON ri.FacilityID = f.FacilityID
WHERE ri.Quantity <= ri.MinimumThreshold;