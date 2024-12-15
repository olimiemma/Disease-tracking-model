-- First, create a new schema for our data warehouse
CREATE SCHEMA disease_dw;

-- Set search path to use our new schema
SET search_path TO disease_dw;

-- Create Dimension Tables
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(10) NOT NULL,
    Week INT NOT NULL,
    DayOfWeek INT NOT NULL,
    IsWeekend BOOLEAN NOT NULL,
    Season VARCHAR(10),
    CONSTRAINT valid_date UNIQUE (FullDate)
);

CREATE TABLE DimPatient (
    PatientKey SERIAL PRIMARY KEY,
    PatientID INT NOT NULL,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DateOfBirth DATE,
    Gender VARCHAR(20),
    BloodType VARCHAR(5),
    AgeGroup VARCHAR(20),
    RiskCategory VARCHAR(20),
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BOOLEAN DEFAULT TRUE,
    CONSTRAINT patient_version UNIQUE (PatientID, StartDate)
);

CREATE TABLE DimDisease (
    DiseaseKey SERIAL PRIMARY KEY,
    DiseaseID INT NOT NULL,
    DiseaseName VARCHAR(100) NOT NULL,
    Classification VARCHAR(100),
    IsCommunicable BOOLEAN,
    VariantName VARCHAR(100),
    VariantSeverity VARCHAR(50),
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BOOLEAN DEFAULT TRUE,
    CONSTRAINT disease_version UNIQUE (DiseaseID, StartDate)
);

CREATE TABLE DimLocation (
    LocationKey SERIAL PRIMARY KEY,
    RegionID INT NOT NULL,
    Country VARCHAR(100) NOT NULL,
    State VARCHAR(100),
    City VARCHAR(100),
    Population INT,
    PopulationDensity DECIMAL(10,2),
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BOOLEAN DEFAULT TRUE,
    CONSTRAINT location_version UNIQUE (RegionID, StartDate)
);

CREATE TABLE DimProvider (
    ProviderKey SERIAL PRIMARY KEY,
    ProviderID INT NOT NULL,
    FullName VARCHAR(100),
    Specialty VARCHAR(100),
    YearsOfExperience INT,
    IsActive BOOLEAN,
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BOOLEAN DEFAULT TRUE,
    CONSTRAINT provider_version UNIQUE (ProviderID, StartDate)
);

CREATE TABLE DimFacility (
    FacilityKey SERIAL PRIMARY KEY,
    FacilityID INT NOT NULL,
    FacilityName VARCHAR(200),
    FacilityType VARCHAR(50),
    Capacity INT,
    HasEmergencyRoom BOOLEAN,
    StartDate DATE NOT NULL,
    EndDate DATE,
    IsCurrent BOOLEAN DEFAULT TRUE,
    CONSTRAINT facility_version UNIQUE (FacilityID, StartDate)
);

-- Create Fact Tables
CREATE TABLE FactCases (
    CaseKey SERIAL PRIMARY KEY,
    PatientKey INT REFERENCES DimPatient(PatientKey),
    DiseaseKey INT REFERENCES DimDisease(DiseaseKey),
    LocationKey INT REFERENCES DimLocation(LocationKey),
    DateKey INT REFERENCES DimDate(DateKey),
    ProviderKey INT REFERENCES DimProvider(ProviderKey),
    FacilityKey INT REFERENCES DimFacility(FacilityKey),
    Severity VARCHAR(50),
    LengthOfStay INT,
    Outcome VARCHAR(50),
    TreatmentCost DECIMAL(10,2)
);

CREATE TABLE FactTests (
    TestKey SERIAL PRIMARY KEY,
    PatientKey INT REFERENCES DimPatient(PatientKey),
    DiseaseKey INT REFERENCES DimDisease(DiseaseKey),
    LocationKey INT REFERENCES DimLocation(LocationKey),
    DateKey INT REFERENCES DimDate(DateKey),
    ProviderKey INT REFERENCES DimProvider(ProviderKey),
    FacilityKey INT REFERENCES DimFacility(FacilityKey),
    TestType VARCHAR(100),
    Result VARCHAR(20),
    TestCost DECIMAL(10,2)
);

CREATE TABLE FactOutbreaks (
    OutbreakKey SERIAL PRIMARY KEY,
    DiseaseKey INT REFERENCES DimDisease(DiseaseKey),
    LocationKey INT REFERENCES DimLocation(LocationKey),
    StartDateKey INT REFERENCES DimDate(DateKey),
    EndDateKey INT REFERENCES DimDate(DateKey),
    TotalCases INT,
    MortalityRate DECIMAL(5,2),
    EconomicImpact DECIMAL(15,2)
);

CREATE TABLE FactInventory (
    InventoryKey SERIAL PRIMARY KEY,
    FacilityKey INT REFERENCES DimFacility(FacilityKey),
    DateKey INT REFERENCES DimDate(DateKey),
    ResourceType VARCHAR(100),
    Quantity INT,
    Value DECIMAL(10,2),
    DaysOfSupply INT
);

-- Create indexes for better query performance
CREATE INDEX idx_factcases_date ON FactCases(DateKey);
CREATE INDEX idx_facttests_date ON FactTests(DateKey);
CREATE INDEX idx_factoutbreaks_dates ON FactOutbreaks(StartDateKey, EndDateKey);
CREATE INDEX idx_factinventory_date ON FactInventory(DateKey);