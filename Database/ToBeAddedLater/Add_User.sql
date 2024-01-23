DROP TYPE create_user_request_type;
CREATE TYPE create_user_request_type AS (
  first_name VARCHAR,
  last_name VARCHAR,
  email VARCHAR,
  user_role user_role_enum,
  role_id INTEGER,
  date_of_birth DATE,
  annual_leave_year_start_date DATE
);

DROP TYPE IF EXISTS create_user_request_type;
CREATE TYPE create_user_request_type AS (
  first_name VARCHAR,
  last_name VARCHAR,
  email VARCHAR,
  user_role user_role_enum,
  role_id INTEGER,
  date_of_birth DATE,
  annual_leave_year_start_date DATE
);

CREATE OR REPLACE FUNCTION add_user(
  IN user_to_be_added create_user_request_type,
  IN my_id INT,
  IN my_role user_role_enum,
  IN company_id INT
)
RETURNS users
LANGUAGE plpgsql
AS $$
DECLARE
   pcompany_annual_leave_year_start_date DATE;
   prole_id INTEGER;
   company_annual_leave_year_start_date DATE;
   inserted_user users;
BEGIN

	IF user_to_be_added.user_role = 'manager' THEN
		IF NOT EXISTS (
			SELECT id 
			FROM roles
			WHERE id = user_to_be_added.role_id AND company_id = company_id
	 	) THEN
			RAISE EXCEPTION 'Role does not exist for the manager';
	  	END IF;
	  	
	  	prole_id := user_to_be_added.role_id;
	ELSE
		prole_id := NULL;
	END IF;
	
	IF user_to_be_added.annual_leave_year_start_date IS NOT NULL THEN
  		SELECT annual_leave_start_date INTO company_annual_leave_year_start_date
  		FROM companies
  		WHERE id = company_id;
	ELSE
  		pcompany_annual_leave_year_start_date := user_to_be_added.annual_leave_year_start_date;
	END IF;
	
	INSERT INTO users (
			company_id, 
			first_name, 
			last_name, 
			email, 
			date_of_birth, 
			user_role, 
			added_by_user, 
			added_by_operator, 
			annual_leave_start_date, 
			role_id
		) VALUES (
			company_id, 
			user_to_be_added.first_name, 
			user_to_be_added.last_name, 
			user_to_be_added.email, 
			user_to_be_added.date_of_birth, 
			user_to_be_added.user_role, 
			my_id, 
			0,
			company_annual_leave_year_start_date,
			prole_id
		) RETURNING * INTO inserted_user;

	IF user_to_be_added.user_role <> 'admin' THEN
		INSERT INTO hierarchies (manager_id, subordinate_id)
		VALUES (my_id, inserted_user.id);
	END IF;

	RETURN inserted_user;
END $$;