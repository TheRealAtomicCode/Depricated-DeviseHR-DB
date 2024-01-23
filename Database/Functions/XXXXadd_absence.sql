  -- check if absence type exists
  -- select last contract
  -- check if contract is found, error if no
  -- check if absence falls in contract timeframe

  -- check the termtime

  -- check if absence exists in timeframe

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
  LIMIT 1;

    -- If no contract is found, raise an exception or handle the error as appropriate
  IF selected_contract IS NULL THEN
    RAISE EXCEPTION 'Contract does not exist';
  END IF;

  -- check if start date of absence is before start date of contract if contract has start date
  IF selected_contract.start_date IS NOT NULL AND pStart_date < selected_contract.start_date THEN
	  RAISE EXCEPTION 'The absence start date cannot be before the contract start date';
  END IF;

  -- check if end date of absence is after end date of contract if contract has end date
  IF selected_contract.end_date IS NOT NULL AND pEnd_date > selected_contract.end_date THEN
    RAISE EXCEPTION 'The absence end date cannot be after the contract end date';
  END IF;

  --
  --
  --
  --
  --
  -- check the term time and if the date is during the term time off for the user then fo not allow adding an absence
  --
  --
  --
  --
  --
  --

  -- check if absense already exists in given time
  IF EXISTS (SELECT id FROM absences WHERE user_id = pUser_id 
              AND company_id = pCompany_id AND contract_id = selected_contract.id 
              AND (pStart_date >= start_date AND pStart_date <= end_date) 
              OR (pEnd_date >= start_date AND pEnd_date <= end_date)
			        OR (pStart_date <= start_date AND pEnd_date >= end_date)) 
              THEN
                    RAISE EXCEPTION 'Absence already exists in given time';
  END IF;
  
  -- If the user's contract type is "variable"
  IF selected_contract.contract_type = 'variable'::Contract_Type_Enum THEN
    -- If the user's leave is in days
    IF selected_contract.is_leave_in_days THEN
      -- Add the user's leave in days without checking WTP or term time
	    IF pStart_date != pEnd_date AND (pIs_first_half_day = true OR pIs_first_half_day = false) THEN
	      RAISE EXCEPTION 'You can not have a half day absence in multiple days';
      END IF;

	    -- insert in days
      INSERT INTO absences
      (user_id, company_id, contract_id, start_date, end_date, is_first_half_day, leave_is_in_days, start_time, end_time, absence_types, comments, added_by, approved, approved_by_admin, days_deducted)
      VALUES
      (pUser_id, pCompany_id, selected_contract.id, pStart_date, pEnd_date, pIs_first_half_day, true, '00:00:00', '00:00:00', pAbsence_type_id, pComments, pMy_id, pApproved, pApproved_by_admin, pDeducted);
      
    ELSE

	-- insert in hours
      INSERT INTO absences
      (user_id, company_id, contract_id, start_date, end_date, is_first_half_day, leave_is_in_days, start_time, end_time, absence_types, comments, added_by, approved, approved_by_admin, hours_deducted)
      VALUES
      (pUser_id, pCompany_id, selected_contract.id, pStart_date, pEnd_date, false, false, pStart_time, pEnd_time, pAbsence_type_id, pComments, pMy_id, pApproved, pApproved_by_admin, pHours);
      
    END IF;
  END IF;
  
END;
$BODY$;

ALTER FUNCTION public.add_absence(integer, integer, date, date, boolean, time without time zone, time without time zone, character varying, integer, integer, integer, integer, integer)
    OWNER TO postgres;






