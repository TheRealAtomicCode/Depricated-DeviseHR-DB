


CREATE OR REPLACE FUNCTION update_previous_contract_end_date_on_insert()
RETURNS TRIGGER AS $$
DECLARE
    last_contract Contracts;
    new_start_day INT;
    last_end_day INT;
    new_end_date DATE;
 	saved_contracted_start_date TIMESTAMP;
	saved_company_id INT;
BEGIN
    SELECT *
    INTO last_contract
    FROM Contracts
    WHERE user_id = NEW.user_id
    ORDER BY start_date DESC, created_at DESC
    LIMIT 1;


    IF EXISTS (
        SELECT id, is_leave_in_days
        FROM contracts
        WHERE user_id = NEW.user_id AND is_leave_in_days != NEW.is_leave_in_days
      ) THEN
            RAISE EXCEPTION 'New contracts must match the time format for previous contracts, or update the previous contracts from days to hours, or hours to days, if you wish to keep your new contract in the current format.';
    END IF;

    -- Check if there is a previous contract
    IF last_contract.id IS NOT NULL THEN
        -- Check if last contract end date exists
        IF last_contract.end_date IS NOT NULL THEN
            -- Extract day of the month from NEW.start_date and last_contract.end_date
            new_start_day := EXTRACT(DAY FROM NEW.start_date);
            last_end_day := EXTRACT(DAY FROM last_contract.end_date);

            -- Check if new contract start date is after last contract end date
            IF NEW.start_date <= last_contract.end_date THEN
                RAISE EXCEPTION 'New contract start date must be after the last contract end date';
            ELSE
                RETURN NEW;
            END IF;
        ELSE
            new_end_date := NEW.start_date - INTERVAL '1 day';

            UPDATE Contracts
            SET end_date = new_end_date
            WHERE id = last_contract.id;

            RETURN NEW;
        END IF;
    ELSE
		RAISE NOTICE 'made it here';
		-- get leave start date from user
		SELECT contracted_leave_start_date, company_id INTO saved_contracted_start_date, saved_company_id FROM users WHERE id = NEW.user_id;
		
		RAISE NOTICE '%', saved_company_id;
		RAISE NOTICE '%', saved_contracted_start_date;
		
		IF saved_contracted_start_date IS NULL THEN
			RAISE NOTICE 'made it here 2';
			-- get leave start date from company if the user does not have a leave year start date
    		SELECT annual_leave_start_date INTO saved_contracted_start_date FROM companies WHERE id = saved_company_id;
			
			RAISE NOTICE '%', saved_contracted_start_date;
  		END IF;
		
		RAISE NOTICE 'made it here 3';
        -- if no previous contract, then new contract will be added by insert
		INSERT INTO leave_year (user_id, company_id, leave_year_start_date, total_leave_entitlement, total_leave_allowance, added_by)
		VALUES (NEW.user_id, NEW.company_id, saved_contracted_start_date, NEW.contracted_leave_entitlement, NEW.this_contracts_leave_allowence, NEW.user_id);
		
		RAISE NOTICE 'made it here 4';
        RETURN NEW;
		
    END IF;

	-- this code will not run if first contract
	-- update previous contract to end of start of new contract
    UPDATE Contracts
    SET end_date = NEW.start_date
    WHERE id = last_contract.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop the trigger if it already exists
-- DROP TRIGGER IF EXISTS update_contract_end_date_trigger ON Contracts;

-- Create the trigger
CREATE OR REPLACE TRIGGER update_contract_end_date_trigger
BEFORE INSERT ON Contracts
FOR EACH ROW
EXECUTE FUNCTION update_previous_contract_end_date_on_insert();

