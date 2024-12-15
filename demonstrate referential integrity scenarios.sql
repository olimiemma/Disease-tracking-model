-- Scenario 1: Attempting to delete a Disease that has active cases
-- This should fail due to referential integrity
DELETE FROM Disease WHERE DiseaseID = 1;

-- To properly handle this, we need to check for dependencies first:
SELECT 
    d.Name as Disease,
    COUNT(DISTINCT cr.CaseID) as ActiveCases,
    COUNT(DISTINCT dt.TestID) as RelatedTests,
    COUNT(DISTINCT do.OutbreakID) as ActiveOutbreaks
FROM Disease d
LEFT JOIN Case_Record cr ON d.DiseaseID = cr.DiseaseID
LEFT JOIN Disease_Test dt ON d.DiseaseID = dt.DiseaseID
LEFT JOIN Disease_Outbreak do ON d.DiseaseID = do.DiseaseID
WHERE d.DiseaseID = 1
GROUP BY d.DiseaseID, d.Name;

-- Scenario 2: What happens when a Healthcare Provider leaves?
-- First, reassign their active cases to another provider
UPDATE Case_Record
SET ProviderID = 22  -- New provider
WHERE ProviderID = 21 AND DischargeDate IS NULL;

-- Then, reassign their scheduled tests
UPDATE Disease_Test
SET ProviderID = 22
WHERE ProviderID = 21 AND TestDate >= CURRENT_DATE;

-- Only then can we safely remove the provider
DELETE FROM Healthcare_Provider WHERE ProviderID = 21;

-- Scenario 3: Facility Closure/Merger
-- First, identify all affected records
WITH FacilityImpact AS (
    SELECT 
        'Active Cases' as RecordType,
        COUNT(*) as Count
    FROM Case_Record 
    WHERE FacilityID = 1 AND DischargeDate IS NULL
    UNION ALL
    SELECT 
        'Scheduled Tests',
        COUNT(*)
    FROM Disease_Test 
    WHERE FacilityID = 1 AND TestDate >= CURRENT_DATE
    UNION ALL
    SELECT 
        'Assigned Staff',
        COUNT(*)
    FROM Healthcare_Provider 
    WHERE FacilityID = 1
)
SELECT * FROM FacilityImpact;

-- Transfer all resources to another facility
UPDATE Resource_Inventory
SET FacilityID = 2,
    Notes = Notes || ' Transferred from Facility 1 on ' || CURRENT_DATE
WHERE FacilityID = 1;

-- Transfer all staff to new facility
UPDATE Healthcare_Provider
SET FacilityID = 2,
    ContactInfo = ContactInfo || ' (Transferred from Facility 1)'
WHERE FacilityID = 1;

-- Scenario 4: Safe Region Merging
-- First, update all related records to new region
BEGIN TRANSACTION;

    -- Update patients
    UPDATE Patient 
    SET RegionID = 2
    WHERE RegionID = 1;
    
    -- Update facilities
    UPDATE Healthcare_Facility
    SET RegionID = 2
    WHERE RegionID = 1;
    
    -- Update disease outbreaks
    UPDATE Disease_Outbreak
    SET RegionID = 2
    WHERE RegionID = 1;
    
    -- Now we can safely remove the old region
    DELETE FROM Region WHERE RegionID = 1;

COMMIT;

-- Scenario 5: Variant Tracking
-- Attempting to delete a variant that has associated cases
DELETE FROM Disease_Variant WHERE VariantID = 1;

-- Proper way: Archive the variant instead
UPDATE Disease_Variant
SET DominantRegion = NULL,
    TransmissionRate = NULL,
    Severity = 'Historical'
WHERE VariantID = 1;