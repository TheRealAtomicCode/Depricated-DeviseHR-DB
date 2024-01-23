
-- new plan

------ do NOT FORGET
------ do not allow annual leave between 2 annual leave years

  -- select contracts during the time of absence, none discarded contracts
  -- check if contract is found
  -- check if 2 different contracts were found
     -- check if they are back to back
  
  -- check if term time exists

    -- if absence is variable
     -- if absence is in days
        -- add absence in days
     -- else
        -- add absence in hours


CREATE OR REPLACE FUNCTION public.add_absence(
	puser_id integer,
	pabsence_type_id integer,
	pstart_date date,
	pend_date date,
	pis_first_half_day boolean,
	pstart_time time without time zone,
	pend_time time without time zone,
	pcomments character varying,
	pmy_id integer,
	pcompany_id integer,
	papproved integer,
	papproved_by_admin integer,
  pDeducted integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
  selected_contract contracts%ROWTYPE;
BEGIN
  
  -- Select the current absence type to check if it exists
  IF NOT EXISTS (SELECT id FROM absence_types WHERE id = pAbsence_type_id) THEN
    RAISE EXCEPTION 'Absence does not exist';
  END IF;

  -- Select the current contract for the user
  SELECT 
    *
  INTO selected_contract
  FROM contracts
  WHERE 
    user_id = pUser_id AND 
    company_id = company_id AND 
    (start_date <= pStart_date AND end_date >= pStart_date) OR 
    (start_date <= pStart_date AND end_date IS NULL)
  LIMIT 2;





 
  








END;
$BODY$;

ALTER FUNCTION public.add_absence(integer, integer, date, date, boolean, time without time zone, time without time zone, character varying, integer, integer, integer, integer, integer)
    OWNER TO postgres;


































































		
	






CREATE OR REPLACE FUNCTION check_contract_matching(absenceStartDate date, absenceEndDate date)
RETURNS BOOLEAN LANGUAGE plpgsql AS
$$
DECLARE 
   first_contract_start_date date;
   first_contract_end_date date;
   last_contract_start_date date;
   last_contract_end_date date;
   success boolean;
BEGIN 

	SELECT start_date, end_date
	INTO first_contract_start_date, first_contract_end_date
	FROM contracts
	WHERE user_id = 2
		AND company_id = 1
		AND (absenceStartDate >= start_date AND absenceStartDate <= end_date);

	SELECT start_date, end_date
	INTO last_contract_start_date, last_contract_end_date
	FROM contracts
	WHERE user_id = 2
		AND company_id = 1
    	AND (absenceEndDate >= start_date AND absenceEndDate <= end_date)
    	OR (absenceEndDate >= start_date AND end_date IS NULL);
	
	-- Check if the first and last contracts match
	IF ((first_contract_start_date = last_contract_start_date 
		AND first_contract_end_date = last_contract_end_date)
	   	OR (first_contract_start_date = last_contract_start_date 
		   AND (first_contract_end_date IS NULL AND last_contract_end_date IS NULL))) THEN
		success := true;
	ELSE
		-- Check if the last contract starts a day after the first contract ends
		IF (last_contract_start_date = first_contract_end_date + INTERVAL '1 day') THEN
			success := true;
		ELSE
			success := false;
		END IF;
	END IF;
	
	-- Return the result
	RETURN success;
	
END $$;


SELECT check_contract_matching('2023-06-05', '2023-06-09');







