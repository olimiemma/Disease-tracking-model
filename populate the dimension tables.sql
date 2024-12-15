-- 1. Populate DimDate (for the next 5 years)
INSERT INTO disease_dw.DimDate (DateKey, FullDate, Year, Quarter, Month, MonthName, Week, DayOfWeek, IsWeekend, Season)
SELECT 
    TO_CHAR(dt, 'YYYYMMDD')::INT AS DateKey,
    dt AS FullDate,
    EXTRACT(YEAR FROM dt) AS Year,
    EXTRACT(QUARTER FROM dt) AS Quarter,
    EXTRACT(MONTH FROM dt) AS Month,
    TO_CHAR(dt, 'Month') AS MonthName,
    EXTRACT(WEEK FROM dt) AS Week,
    EXTRACT(DOW FROM dt) AS DayOfWeek,
    CASE WHEN EXTRACT(DOW FROM dt) IN (0, 6) THEN TRUE ELSE FALSE END AS IsWeekend,
    CASE 
        WHEN EXTRACT(MONTH FROM dt) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM dt) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM dt) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS Season
FROM generate_series(
    '2023-01-01'::DATE,
    '2028-12-31'::DATE,
    '1 day'::INTERVAL
) dt;

-- 2. Populate DimPatient
INSERT INTO disease_dw.DimPatient (
    PatientID, FirstName, LastName, DateOfBirth, 
    Gender, BloodType, AgeGroup, RiskCategory, StartDate
)
SELECT 
    p.PatientID,
    p.FirstName,
    p.LastName,
    p.DateOfBirth,
    p.Gender,
    p.BloodType,
    CASE 
        WHEN DATE_PART('year', AGE(CURRENT_DATE, p.DateOfBirth)) < 18 THEN 'Child'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, p.DateOfBirth)) < 30 THEN 'Young Adult'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, p.DateOfBirth)) < 50 THEN 'Adult'
        WHEN DATE_PART('year', AGE(CURRENT_DATE, p.DateOfBirth)) < 70 THEN 'Middle Aged'
        ELSE 'Senior'
    END AS AgeGroup,
    CASE 
        WHEN p.MedicalHistory LIKE '%Diabetes%' OR 
             p.MedicalHistory LIKE '%Heart%' THEN 'High'
        WHEN p.MedicalHistory IS NOT NULL THEN 'Medium'
        ELSE 'Low'
    END AS RiskCategory,
    CURRENT_DATE AS StartDate
FROM public.Patient p;

-- 3. Populate DimDisease
INSERT INTO disease_dw.DimDisease (
    DiseaseID, DiseaseName, Classification, 
    IsCommunicable, StartDate
)
SELECT 
    d.DiseaseID,
    d.Name,
    d.Classification,
    d.IsCommunicable,
    CURRENT_DATE AS StartDate
FROM public.Disease d;

-- 4. Populate DimLocation
INSERT INTO disease_dw.DimLocation (
    RegionID, Country, State, City, 
    Population, PopulationDensity, StartDate
)
SELECT 
    r.RegionID,
    r.Country,
    r.State,
    r.City,
    r.Population,
    r.Population::decimal / NULLIF(POWER(((r.longitude - r.latitude) * 111), 2), 0) AS PopulationDensity,
    CURRENT_DATE AS StartDate
FROM public.Region r;

-- 5. Populate DimProvider
INSERT INTO disease_dw.DimProvider (
    ProviderID, FullName, Specialty, 
    IsActive, StartDate
)
SELECT 
    hp.ProviderID,
    hp.FirstName || ' ' || hp.LastName AS FullName,
    hp.Specialty,
    TRUE AS IsActive,
    CURRENT_DATE AS StartDate
FROM public.Healthcare_Provider hp;

-- 6. Populate DimFacility
INSERT INTO disease_dw.DimFacility (
    FacilityID, FacilityName, FacilityType, 
    Capacity, HasEmergencyRoom, StartDate
)
SELECT 
    hf.FacilityID,
    hf.Name AS FacilityName,
    hf.FacilityType,
    hf.BedCapacity AS Capacity,
    hf.HasEmergencyRoom,
    CURRENT_DATE AS StartDate
FROM public.Healthcare_Facility hf;