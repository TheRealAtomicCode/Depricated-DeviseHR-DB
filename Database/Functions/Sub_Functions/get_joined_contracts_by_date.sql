CREATE OR REPLACE FUNCTION get_joined_contracts_by_date(absenceStartDate date, absenceEndDate date)
RETURNS TABLE (contract_row contracts) LANGUAGE plpgsql AS
$$
DECLARE 
   first_contract_row contracts;
   last_contract_row contracts;
BEGIN 
    SELECT *
    INTO first_contract_row
    FROM contracts
    WHERE user_id = 2
        AND company_id = 1
        AND (absenceStartDate >= start_date AND absenceStartDate <= end_date
            OR absenceEndDate >= start_date AND end_date IS NULL);

    SELECT *
    INTO last_contract_row
    FROM contracts
    WHERE user_id = 2
        AND company_id = 1
        AND (absenceEndDate >= start_date AND absenceEndDate <= end_date
            OR absenceEndDate >= start_date AND end_date IS NULL);

    -- Check if the first and last contracts match
    IF (first_contract_row = last_contract_row) THEN
        RETURN QUERY SELECT *
            FROM contracts
            WHERE id = first_contract_row.id;
    ELSE
        -- Check if the last contract starts a day after the first contract ends
        IF (last_contract_row.start_date = first_contract_row.end_date + INTERVAL '1 day') THEN
            RETURN QUERY SELECT *
                FROM contracts
                WHERE (id = first_contract_row.id OR id = last_contract_row.id);
        ELSE
            RETURN;
        END IF;
    END IF;
END $$;