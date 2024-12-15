-- Core Disease Information
CREATE TABLE Disease (
    DiseaseID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Classification VARCHAR(100),
    Description TEXT,
    IsCommunicable BOOLEAN,
    Symptoms TEXT,
    TransmissionMethod TEXT,
    IncubationPeriodDays INTEGER,
    MortalityRate DECIMAL(5,2),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Disease Variants/Strains
CREATE TABLE Disease_Variant (
    VariantID SERIAL PRIMARY KEY,
    DiseaseID INTEGER REFERENCES Disease(DiseaseID),
    Name VARCHAR(100) NOT NULL,
    FirstIdentified DATE,
    Characteristics TEXT,
    TransmissionRate DECIMAL(4,2),
    Severity VARCHAR(50),
    DominantRegion INTEGER,  -- References Region
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Geographic Information
CREATE TABLE Region (
    RegionID SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    State VARCHAR(100),
    City VARCHAR(100),
    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6),
    Population INTEGER,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Healthcare Facilities
CREATE TABLE Healthcare_Facility (
    FacilityID SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    RegionID INTEGER REFERENCES Region(RegionID),
    FacilityType VARCHAR(50), -- Hospital, Clinic, Testing Center, etc.
    BedCapacity INTEGER,
    ICUCapacity INTEGER,
    HasEmergencyRoom BOOLEAN,
    SpecialtyUnits TEXT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Healthcare Providers
CREATE TABLE Healthcare_Provider (
    ProviderID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialty VARCHAR(100),
    LicenseNumber VARCHAR(50) UNIQUE,
    FacilityID INTEGER REFERENCES Healthcare_Facility(FacilityID),
    ContactInfo TEXT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Patients
CREATE TABLE Patient (
    PatientID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(20),
    BloodType VARCHAR(5),
    RegionID INTEGER REFERENCES Region(RegionID),
    ContactNumber VARCHAR(20),
    EmailAddress VARCHAR(100),
    MedicalHistory TEXT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Disease Tests
CREATE TABLE Disease_Test (
    TestID SERIAL PRIMARY KEY,
    PatientID INTEGER REFERENCES Patient(PatientID),
    DiseaseID INTEGER REFERENCES Disease(DiseaseID),
    TestDate DATE NOT NULL,
    TestType VARCHAR(100),
    Result VARCHAR(20),
    FacilityID INTEGER REFERENCES Healthcare_Facility(FacilityID),
    ProviderID INTEGER REFERENCES Healthcare_Provider(ProviderID),
    Notes TEXT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Case Management
CREATE TABLE Case_Record (
    CaseID SERIAL PRIMARY KEY,
    PatientID INTEGER REFERENCES Patient(PatientID),
    DiseaseID INTEGER REFERENCES Disease(DiseaseID),
    VariantID INTEGER REFERENCES Disease_Variant(VariantID),
    DiagnosisDate DATE,
    Severity VARCHAR(50),
    Symptoms TEXT,
    Treatment TEXT,
    Outcome VARCHAR(50),
    DischargeDate DATE,
    FacilityID INTEGER REFERENCES Healthcare_Facility(FacilityID),
    ProviderID INTEGER REFERENCES Healthcare_Provider(ProviderID),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Treatment Protocols
CREATE TABLE Treatment_Protocol (
    ProtocolID SERIAL PRIMARY KEY,
    DiseaseID INTEGER REFERENCES Disease(DiseaseID),
    Name VARCHAR(200),
    Description TEXT,
    Medications TEXT,
    Procedures TEXT,
    EffectiveDate DATE,
    Status VARCHAR(50),
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Resource Management
CREATE TABLE Resource_Inventory (
    InventoryID SERIAL PRIMARY KEY,
    FacilityID INTEGER REFERENCES Healthcare_Facility(FacilityID),
    ResourceType VARCHAR(100),
    Quantity INTEGER,
    MinimumThreshold INTEGER,
    LastRestocked DATE,
    ExpiryDate DATE,
    Notes TEXT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Disease Outbreaks
CREATE TABLE Disease_Outbreak (
    OutbreakID SERIAL PRIMARY KEY,
    DiseaseID INTEGER REFERENCES Disease(DiseaseID),
    RegionID INTEGER REFERENCES Region(RegionID),
    StartDate DATE,
    EndDate DATE,
    TotalCases INTEGER,
    Status VARCHAR(50),
    ContainmentMeasures TEXT,
    Notes TEXT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for commonly queried columns
CREATE INDEX idx_disease_name ON Disease(Name);
CREATE INDEX idx_patient_region ON Patient(RegionID);
CREATE INDEX idx_case_disease ON Case_Record(DiseaseID);
CREATE INDEX idx_test_patient ON Disease_Test(PatientID);
CREATE INDEX idx_test_disease ON Disease_Test(DiseaseID);
CREATE INDEX idx_facility_region ON Healthcare_Facility(RegionID);
CREATE INDEX idx_outbreak_disease ON Disease_Outbreak(DiseaseID);
CREATE INDEX idx_outbreak_region ON Disease_Outbreak(RegionID);