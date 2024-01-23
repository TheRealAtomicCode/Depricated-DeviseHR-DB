-- droop triggers
DROP TRIGGER IF EXISTS update_contract_end_date_trigger ON Contracts;
DROP FUNCTION IF EXISTS update_previous_contract_end_date_on_insert();

DROP TRIGGER IF EXISTS check_leave_duration_trigger ON Absences;
DROP FUNCTION IF EXISTS check_leave_duration();

-- drop functions
DROP FUNCTION IF EXISTS add_absence;
DROP FUNCTION IF EXISTS update_last_contract_end_date;
DROP FUNCTION IF EXISTS edit_subordinates;
DROP FUNCTION IF EXISTS edit_user_roles;

-- drop tables
DROP TABLE IF EXISTS Terms CASCADE;
DROP TABLE IF EXISTS Absences CASCADE;
DROP TABLE IF EXISTS Working_Patterns CASCADE;
DROP TABLE IF EXISTS Discarded_Contracts CASCADE;
DROP TABLE IF EXISTS Absence_Types CASCADE;

DROP TABLE IF EXISTS Hierarchies CASCADE;
DROP TABLE IF EXISTS Contracts CASCADE;
DROP TYPE IF EXISTS Contract_Type_Enum CASCADE;


DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Roles;
DROP TABLE IF EXISTS Companies;
DROP TABLE IF EXISTS Notes;
DROP TABLE IF EXISTS Operators;
DROP TYPE IF EXISTS operator_role_enum;
DROP TYPE IF EXISTS user_role_enum;

-- drop types
DROP TYPE IF EXISTS contract_record;
DROP TYPE IF EXISTS user_role_enum;
DROP TYPE IF EXISTS Contract_Type_Enum;
DROP TYPE IF EXISTS contract_record;