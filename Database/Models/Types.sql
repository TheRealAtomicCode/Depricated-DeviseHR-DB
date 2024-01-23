-- CREATE TYPE operator_role_enum AS ENUM ('root', 'sudo', 'admin', 'manager', 'employee'); 1=> root, 2=> sudo, 3=> admin, 4=> manager, 5=> employee
-- CREATE TYPE user_role_enum AS ENUM ('admin', 'manager', 'employee'); 1=> admin, 2=> manager, 3=> employee


-- CREATE TYPE Contract_Type_Enum AS ENUM ('regular', 'variable', 'agency'); 1=> agency 2=> variable, 3=> regular

-- update last contract end date
CREATE TYPE contract_record AS (
  id INT,
  start_date DATE,
  end_date DATE,
  updated_by INT
);
