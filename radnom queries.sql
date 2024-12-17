SELECT ProviderID FROM Healthcare_Provider ORDER BY ProviderID;

-- First, let's check our tables
SELECT * FROM information_schema.tables 
WHERE table_schema = 'disease_dw';

-- Then set our search path
SET search_path TO disease_dw, public;