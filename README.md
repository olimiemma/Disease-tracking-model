# Disease Tracking and Analysis System

## Project Overview
A comprehensive database system for tracking and analyzing multiple infectious diseases across different geographic locations. The system supports both operational (OLTP) and analytical (OLAP) capabilities through a well-designed relational database and data warehouse implementation.

## Business Problem
Healthcare organizations need to effectively track and analyze disease outbreaks, monitor patient cases, manage resources, and analyze patterns across different regions. This system provides:
- Real-time disease outbreak tracking
- Patient case management
- Testing and treatment monitoring
- Resource allocation tracking
- Comprehensive analytical capabilities

## Technical Architecture

### OLTP Database Schema
Core entities include:
- Disease and Disease Variants
- Patients and Cases
- Healthcare Providers and Facilities
- Testing and Treatment Records
- Geographic Locations
- Resource Inventory

### Data Warehouse Schema
Star schema design with:
- Fact Tables:
  - FactCases (patient cases)
  - FactTests (testing records)
  - FactOutbreaks (disease outbreaks)
  - FactInventory (resource tracking)
- Dimension Tables:
  - DimPatient
  - DimDisease
  - DimLocation
  - DimDate
  - DimProvider
  - DimFacility

## Key Features

### Disease Tracking
- Multiple disease tracking capabilities
- Variant monitoring
- Geographic spread analysis
- Patient case management

### Testing Management
- Test result tracking
- Testing trends analysis
- Facility performance monitoring
- Cost analysis

### Resource Management
- Inventory tracking
- Resource allocation
- Facility capacity monitoring
- Supply chain management

### Analytics
- Disease spread patterns
- Testing effectiveness
- Resource utilization
- Outbreak impact assessment
- Population health metrics

## Implementation Details

### Technologies Used
- PostgreSQL 
- Custom ETL processes
- Analytical queries and views

### Database Structure
- Separate schemas for OLTP and Data Warehouse
- Comprehensive indexing strategy
- Referential integrity enforcement
- Data quality constraints

## Sample Queries and Analysis

### Operational Queries
```sql
-- Disease outbreak tracking
-- Patient case management
-- Resource allocation
-- Testing management
```

### Analytical Queries
```sql
-- Geographic spread analysis
-- Testing effectiveness metrics
-- Resource utilization patterns
-- Outbreak impact assessment
```

## Installation and Setup

1. Create PostgreSQL database
```sql
CREATE DATABASE disease_tracking;
```

2. Create schemas
```sql
CREATE SCHEMA public;
CREATE SCHEMA disease_dw;
```

3. Run table creation scripts
```sql
-- Run OLTP tables script
-- Run Data Warehouse tables script
```

4. Run ETL processes
```sql
-- Run dimension table population
-- Run fact table population
```

## Data Model

### OLTP Schema

![schema](https://github.com/user-attachments/assets/1d142647-d446-4d22-b929-3f1e460e8c05)

### Data Warehouse Schema
 Star Schema Diagram
![Screenshot from 2024-12-14 23-21-44](https://github.com/user-attachments/assets/afc650e0-479b-4f35-8953-f53f467e2d7d)

## Usage Examples

### Basic Operations
```sql
-- Example operational queries
```

### Analytics
```sql
-- Example analytical queries
```

## Maintenance and Updates

### Daily Operations
- Test result entry
- Case management
- Resource tracking

### ETL Processes
- Daily dimension updates
- Fact table population
- Data quality checks

## Future Enhancements
1. Real-time reporting dashboard
2. Predictive analytics integration
3. Mobile application interface
4. Advanced visualization capabilities
5. Machine learning integration for outbreak prediction

## Contributors
1.Emmanuel Olimi K.

2.Claude.ai

## License
Copyright (c) 2024 Emmanuel Olimi K.

## Contact
[[Linkedin]](https://www.linkedin.com/in/olimiemma/)
