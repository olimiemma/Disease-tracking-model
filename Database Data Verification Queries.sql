-- 1. Basic Count Checks for All Tables
SELECT 
    'Disease' as table_name, COUNT(*) as record_count FROM Disease UNION ALL
SELECT 'Disease_Variant', COUNT(*) FROM Disease_Variant UNION ALL
SELECT 'Region', COUNT(*) FROM Region UNION ALL
SELECT 'Healthcare_Facility', COUNT(*) FROM Healthcare_Facility UNION ALL
SELECT 'Healthcare_Provider', COUNT(*) FROM Healthcare_Provider UNION ALL
SELECT 'Patient', COUNT(*) FROM Patient UNION ALL
SELECT 'Disease_Test', COUNT(*) FROM Disease_Test UNION ALL
SELECT 'Case_Record', COUNT(*) FROM Case_Record UNION ALL
SELECT 'Treatment_Protocol', COUNT(*) FROM Treatment_Protocol UNION ALL
SELECT 'Resource_Inventory', COUNT(*) FROM Resource_Inventory UNION ALL
SELECT 'Disease_Outbreak', COUNT(*) FROM Disease_Outbreak
ORDER BY table_name;

-- 2. Check Disease Distribution in Tests
SELECT 
    d.Name as Disease,
    COUNT(dt.TestID) as Total_Tests,
    COUNT(CASE WHEN dt.Result = 'Positive' THEN 1 END) as Positive_Cases,
    ROUND(COUNT(CASE WHEN dt.Result = 'Positive' THEN 1 END)::decimal / 
          NULLIF(COUNT(dt.TestID), 0) * 100, 2) as Positivity_Rate
FROM Disease d
LEFT JOIN Disease_Test dt ON d.DiseaseID = dt.DiseaseID
GROUP BY d.DiseaseID, d.Name
ORDER BY Total_Tests DESC;

-- 3. Verify Provider Assignments
SELECT 
    hp.ProviderID,
    hp.FirstName,
    hp.LastName,
    hp.Specialty,
    COUNT(dt.TestID) as Tests_Conducted,
    COUNT(DISTINCT dt.PatientID) as Unique_Patients
FROM Healthcare_Provider hp
LEFT JOIN Disease_Test dt ON hp.ProviderID = dt.ProviderID
GROUP BY hp.ProviderID, hp.FirstName, hp.LastName, hp.Specialty
ORDER BY Tests_Conducted DESC;

-- 4. Check Facility Distribution
SELECT 
    hf.Name as Facility,
    hf.FacilityType,
    COUNT(dt.TestID) as Total_Tests,
    COUNT(DISTINCT dt.PatientID) as Unique_Patients,
    COUNT(DISTINCT dt.ProviderID) as Active_Providers
FROM Healthcare_Facility hf
LEFT JOIN Disease_Test dt ON hf.FacilityID = dt.FacilityID
GROUP BY hf.FacilityID, hf.Name, hf.FacilityType
ORDER BY Total_Tests DESC;

-- 5. Verify Data Integrity
SELECT 'Orphaned Tests' as Check_Type, COUNT(*) as Issue_Count
FROM Disease_Test dt
WHERE NOT EXISTS (SELECT 1 FROM Patient p WHERE p.PatientID = dt.PatientID)
UNION ALL
SELECT 'Invalid Provider References', COUNT(*)
FROM Disease_Test dt
WHERE NOT EXISTS (SELECT 1 FROM Healthcare_Provider hp WHERE hp.ProviderID = dt.ProviderID)
UNION ALL
SELECT 'Invalid Disease References', COUNT(*)
FROM Disease_Test dt
WHERE NOT EXISTS (SELECT 1 FROM Disease d WHERE d.DiseaseID = dt.DiseaseID);

-- 6. Check Date Distributions
SELECT 
    date_trunc('month', TestDate) as Month,
    COUNT(*) as Total_Tests,
    COUNT(CASE WHEN Result = 'Positive' THEN 1 END) as Positive_Cases
FROM Disease_Test
GROUP BY date_trunc('month', TestDate)
ORDER BY Month;

-- 7. Verify Resource Distribution
SELECT 
    hf.Name as Facility,
    ri.ResourceType,
    SUM(ri.Quantity) as Total_Quantity,
    MIN(ri.LastRestocked) as Last_Restock_Date
FROM Healthcare_Facility hf
JOIN Resource_Inventory ri ON hf.FacilityID = ri.FacilityID
GROUP BY hf.Name, ri.ResourceType
ORDER BY hf.Name, ri.ResourceType;

-- 8. Check Treatment Protocol Coverage
SELECT 
    d.Name as Disease,
    COUNT(tp.ProtocolID) as Protocol_Count,
    STRING_AGG(tp.Name, ', ') as Protocol_Names
FROM Disease d
LEFT JOIN Treatment_Protocol tp ON d.DiseaseID = tp.DiseaseID
GROUP BY d.DiseaseID, d.Name;

-- 9. Regional Distribution Check
SELECT 
    r.Name as Region,
    COUNT(DISTINCT p.PatientID) as Registered_Patients,
    COUNT(DISTINCT dt.TestID) as Total_Tests,
    COUNT(DISTINCT CASE WHEN dt.Result = 'Positive' THEN dt.TestID END) as Positive_Cases
FROM Region r
LEFT JOIN Patient p ON r.RegionID = p.RegionID
LEFT JOIN Disease_Test dt ON p.PatientID = dt.PatientID
GROUP BY r.RegionID, r.Name
ORDER BY Registered_Patients DESC;