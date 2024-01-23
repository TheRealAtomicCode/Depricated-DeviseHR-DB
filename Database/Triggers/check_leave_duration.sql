CREATE OR REPLACE FUNCTION check_leave_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT is_leave_in_days FROM contracts WHERE id = NEW.contract_id) THEN
        IF NEW.days_deducted IS NULL THEN
            RAISE EXCEPTION 'You can not add absences in hours when leave is in days';
        END IF;
    ELSE
        IF NEW.deducted_in_minutes IS NULL THEN
            RAISE EXCEPTION 'You can not add absences in days when leave is in hours';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_leave_duration_trigger
BEFORE INSERT ON absences
FOR EACH ROW
EXECUTE FUNCTION check_leave_duration();
