CREATE FUNCTION update_last_contract_end_date(
  IN userId INT,
  IN myId INT,
  IN companyId INT,
  IN endDateStr VARCHAR
)
RETURNS contract_record AS $$
DECLARE
  last_contract contract_record;
BEGIN
  -- Find the last contract for the given user_id and companyId
  SELECT id, start_date, end_date, updated_by
  INTO last_contract
  FROM contracts
  WHERE user_id = userId AND company_id = companyId
  ORDER BY start_date DESC
  LIMIT 1;

  IF last_contract.start_date IS NOT NULL THEN
    -- Check if the start date is before the provided end date
    IF last_contract.start_date >= endDateStr::date THEN
      -- Throw an error if the start date is not before the provided end date
      RAISE EXCEPTION 'Start date of the last contract is after the provided end date';
    ELSE
      -- Update the end date of the last contract with the provided end date
      UPDATE contracts
      SET end_date = endDateStr::date, updated_by = myId
      WHERE user_id = userId AND company_id = companyId AND id = last_contract.id AND user_id != myId;
    END IF;
  END IF;

  RETURN last_contract;
END;
$$ LANGUAGE plpgsql;

