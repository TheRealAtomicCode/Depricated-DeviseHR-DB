CREATE OR REPLACE FUNCTION update_previous_contract_end_date_on_insert()
RETURNS TRIGGER AS $$
DECLARE
    last_contract Contracts;
    new_start_day INT;
    last_end_day INT;
    new_end_date DATE;
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
        -- if no previous contract, add contract
        RETURN NEW;
    END IF;

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

