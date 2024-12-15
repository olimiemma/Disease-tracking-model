-- First, let's populate core disease information
INSERT INTO Disease (Name, Classification, Description, IsCommunicable, Symptoms, TransmissionMethod, IncubationPeriodDays, MortalityRate) VALUES
('COVID-19', 'Viral', 'SARS-CoV-2 coronavirus disease', true, 'Fever, cough, fatigue, loss of taste/smell', 'Respiratory droplets, airborne', 14, 2.1),
('Influenza A', 'Viral', 'Seasonal flu variant A', true, 'Fever, cough, body aches, fatigue', 'Respiratory droplets', 4, 0.1),
('Tuberculosis', 'Bacterial', 'Mycobacterium tuberculosis infection', true, 'Chronic cough, weight loss, night sweats', 'Airborne', 28, 15.0),
('Measles', 'Viral', 'Highly contagious viral infection', true, 'Rash, fever, cough, runny nose', 'Airborne, direct contact', 14, 0.2),
('Malaria', 'Parasitic', 'Plasmodium parasite infection', false, 'Fever, chills, fatigue, sweating', 'Mosquito vector', 14, 0.3);

-- Disease variants
INSERT INTO Disease_Variant (DiseaseID, Name, FirstIdentified, Characteristics, TransmissionRate, Severity) 
SELECT 
    1, -- COVID-19
    variant_name,
    first_identified_date::DATE,  -- Cast string to DATE
    characteristics,
    transmission_rate,
    severity
FROM (VALUES 
    ('Alpha', '2020-12-01', 'Increased transmissibility', 1.5, 'Moderate'),
    ('Delta', '2021-03-01', 'Higher viral loads', 2.0, 'Severe'),
    ('Omicron', '2021-11-01', 'Immune escape capability', 3.0, 'Moderate')
) AS variants(variant_name, first_identified_date, characteristics, transmission_rate, severity);

-- Regions (using realistic population centers)
INSERT INTO Region (Name, Country, State, City, Latitude, Longitude, Population) VALUES
('Northeast', 'USA', 'New York', 'New York City', 40.7128, -74.0060, 8400000),
('West Coast', 'USA', 'California', 'Los Angeles', 34.0522, -118.2437, 4000000),
('Midwest', 'USA', 'Illinois', 'Chicago', 41.8781, -87.6298, 2700000),
('Southeast', 'USA', 'Florida', 'Miami', 25.7617, -80.1918, 450000),
('Southwest', 'USA', 'Texas', 'Houston', 29.7604, -95.3698, 2300000);

-- Healthcare Facilities
INSERT INTO Healthcare_Facility (Name, RegionID, FacilityType, BedCapacity, ICUCapacity, HasEmergencyRoom, SpecialtyUnits) VALUES
('Metropolitan General', 1, 'Hospital', 1000, 100, true, 'Infectious Disease, ICU, Emergency'),
('Pacific Medical Center', 2, 'Hospital', 800, 80, true, 'ICU, Emergency, Research'),
('Midwest Health', 3, 'Hospital', 600, 60, true, 'General Care, Emergency'),
('Southeast Regional', 4, 'Hospital', 400, 40, true, 'Tropical Disease, Emergency'),
('Southwest Memorial', 5, 'Hospital', 700, 70, true, 'Research, Emergency'),
('Downtown Clinic', 1, 'Clinic', 50, 0, false, 'General Care'),
('West Side Urgent Care', 2, 'Urgent Care', 30, 0, true, 'Emergency'),
('North Side Testing Center', 3, 'Testing Center', 0, 0, false, 'Diagnostics');

-- Healthcare Providers (20 providers across facilities)
INSERT INTO Healthcare_Provider (FirstName, LastName, Specialty, LicenseNumber, FacilityID, ContactInfo)
SELECT 
    'Provider' || id,
    'LastName' || id,
    CASE 
        WHEN id % 5 = 0 THEN 'Infectious Disease'
        WHEN id % 5 = 1 THEN 'Internal Medicine'
        WHEN id % 5 = 2 THEN 'Emergency Medicine'
        WHEN id % 5 = 3 THEN 'Pulmonology'
        ELSE 'General Practice'
    END as specialty,
    'LIC' || LPAD(id::text, 6, '0') as license_number,
    (id % 5) + 1 as facility_id,
    'contact' || id || '@healthcare.org'
FROM generate_series(1, 20) as id;

-- Treatment Protocols
INSERT INTO Treatment_Protocol (DiseaseID, Name, Description, Medications, Procedures, EffectiveDate, Status) VALUES
(1, 'COVID-19 Standard Protocol', 'Standard treatment for mild to moderate cases', 'Antivirals, Supportive Care', 'Oxygen therapy if needed', '2023-01-01', 'Active'),
(1, 'COVID-19 Severe Case Protocol', 'Treatment for severe cases', 'Antivirals, Steroids', 'Ventilation support', '2023-01-01', 'Active'),
(2, 'Influenza Treatment Protocol', 'Standard influenza treatment', 'Oseltamivir, Supportive Care', 'Symptom management', '2023-01-01', 'Active'),
(3, 'TB Treatment Protocol', 'Standard TB treatment', 'RIPE therapy', 'Regular monitoring', '2023-01-01', 'Active'),
(4, 'Measles Management Protocol', 'Supportive care protocol', 'Vitamin A, Supportive Care', 'Isolation, monitoring', '2023-01-01', 'Active');

-- Resource Inventory (initial stock)
INSERT INTO Resource_Inventory (FacilityID, ResourceType, Quantity, MinimumThreshold, LastRestocked, ExpiryDate)
SELECT 
    f.FacilityID,
    rt.resource_type,
    FLOOR(random() * 1000 + 100),
    50,
    '2023-12-01'::date,
    '2024-12-01'::date
FROM Healthcare_Facility f
CROSS JOIN (
    SELECT unnest(ARRAY['Ventilators', 'PPE', 'Test Kits', 'Medications']) AS resource_type
) rt
WHERE f.FacilityType = 'Hospital';