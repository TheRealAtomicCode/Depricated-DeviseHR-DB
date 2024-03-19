CREATE OR REPLACE FUNCTION is_related(p_manager_id INT, p_subordinate_id INT) RETURNS BOOLEAN AS $$
DECLARE
  v_hierarchy_exists BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM hierarchies
    WHERE manager_id = p_manager_id AND subordinate_id = p_subordinate_id
    LIMIT 1
  ) INTO v_hierarchy_exists;

  RETURN v_hierarchy_exists;
END $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION has_manager(p_subordinate_id INT) RETURNS BOOLEAN AS $$
DECLARE
  v_has_manager BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM hierarchies
    WHERE subordinate_id = p_subordinate_id
    LIMIT 1
  ) INTO v_has_manager;

  RETURN v_has_manager;
END $$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION insert_absence(
	p_start_date DATE,
	p_end_date DATE,
	p_start_time TIME,
	p_end_time TIME,
	p_is_half_day BOOLEAN,
	p_absence_type INT,
	p_comment TEXT,
	p_company_id INT,
	p_user_id INT,
	p_my_id INT,
	p_user_type INT
) RETURNS VOID AS $$
DECLARE
  v_leave_year_start_date DATE;
  v_contracts contracts[];
  v_has_manager BOOLEAN;
  v_is_subordinate BOOLEAN;
  v_approved INT;
BEGIN
	
  -- permissions check section
  --
  --
  IF p_my_id = p_user_id THEN
  	
	IF p_user_type = 1 THEN 
		v_has_manager := has_manager(p_my_id);
		
		IF v_has_manager THEN
		   -- request absence
		   v_approved = NULL;
		ELSE
	     -- add absence
		 v_approved = my_id;
		END IF;
		
	ELSE
		-- request
		v_approved = NULL;
	END IF;
		
  ELSE
  
  	IF p_user_type = 1 THEN 
		-- add
		v_approved = my_id
	ELSE IF p_user_type = 2 THEN
		-- check is related
		v_is_subordinate := is_related(p_my_id, p_user_id);
		
		IF v_is_subordinate THEN
		  -- add for other user
		  v_approved = my_id;
		ELSE
		  -- error
		  RAISE EXCEPTION 'Error: Can not add absence for user who is not your subordinate';
		  
		END IF;
	ELSE
		-- error
		RAISE EXCEPTION 'Error: Employees can not add absences for other users';
	END IF;
  
  END IF;
  
  
	

  -- check leave year section 
  --
  --
  SELECT leave_year_start_date INTO v_leave_year_start_date
  FROM leave_year
  WHERE leave_year_start_date <= p_start_date
  ORDER BY leave_year_start_date DESC
  LIMIT 1;
  
  IF v_leave_year_start_date IS NULL THEN
    RAISE EXCEPTION 'Error: No leave year was found.';
  END IF;

  -- check if absence dates are located within leave year range
  IF v_leave_year_start_date + INTERVAL '1 year' <= p_start_date THEN
    RAISE EXCEPTION 'Error: Absence start date is out of scope of leave year.';
  END IF;
  IF v_leave_year_start_date + INTERVAL '1 year' <= p_end_date THEN
    RAISE EXCEPTION 'Error: Absence end date is out of scope of leave year.';
  END IF;



  -- contracts section
  --
  --
  -- Retrieve contracts based on specified dates and store them in the array
  WITH subquery AS (
    SELECT *
    FROM contracts
    WHERE start_date <= p_start_date
      AND (end_date >= p_start_date OR end_date IS NULL)
    UNION
    SELECT *
    FROM contracts
    WHERE start_date <= p_end_date AND (end_date >= p_end_date OR end_date IS NULL)
  )
  SELECT ARRAY_AGG(sq)
  INTO v_contracts
  FROM subquery AS sq;
  
  -- check contracts 
  IF array_length(v_contracts, 1) > 1 THEN
    IF v_contracts[2].end_date <> v_contracts[1].start_date + INTERVAL '-1 day' THEN
      RAISE EXCEPTION 'Error: can not add absence between 2 contracts that have a gap between.';
    END IF;
  ELSE
  	IF v_contracts[1].start_date > p_start_date OR v_contracts[1].end_date < p_end_date THEN
	  RAISE EXCEPTION 'Provided absence falls out of scope with existing contracts.';
	END IF;
  END IF;
	
	
	
	
  -- Raise the contracts section
  --
  --
  RAISE NOTICE 'Contracts:';
  RAISE NOTICE '-------------------------------------';
  FOR i IN 1..array_length(v_contracts, 1) LOOP
    RAISE NOTICE 'Id: %, start_date: %, end_date: %', v_contracts[i].id, v_contracts[i].start_date, v_contracts[i].end_date;
  END LOOP;





END $$ LANGUAGE plpgsql;

