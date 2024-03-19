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
	p_my_id INT
) RETURNS VOID AS $$
DECLARE
  v_leave_year_start_date DATE;
  v_contracts contracts[];
BEGIN
	
	

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
  
  -- hey chat gpt, can you please add an if statement to check if the v_contracts has a value in the [1] index and if so, add another if statement inside of it checking if the start_date of v_contracts[0] is exactly 1 day after the end_date of v_contracts[0]
  IF array_length(v_contracts, 1) > 1 THEN
  	RAISE NOTICE 'array has 2 values';
	RAISE NOTICE '%', v_contracts[2].end_date;
	RAISE NOTICE '%', v_contracts[1].start_date + INTERVAL '-1 day';
    IF v_contracts[2].end_date <> v_contracts[1].start_date + INTERVAL '-1 day' THEN
      RAISE EXCEPTION 'Error: can not add absence between 2 contracts that have a gap between.';
    END IF;
  ELSE
  	IF v_contracts[1].start_date > p_start_date OR v_contracts[1].end_date < p_end_date THEN
	  RAISE EXCEPTION 'Provided absence falls out of scope with existing contracts.';
	END IF;
  END IF;
	
  -- Raise the contracts
  RAISE NOTICE 'Contracts:';
  RAISE NOTICE '-------------------------------------';
  FOR i IN 1..array_length(v_contracts, 1) LOOP
    RAISE NOTICE 'Id: %, start_date: %, end_date: %', v_contracts[i].id, v_contracts[i].start_date, v_contracts[i].end_date;
  END LOOP;





END $$ LANGUAGE plpgsql;