CREATE OR REPLACE FUNCTION edit_subordinates(
  IN managers_to_be_added INT[],
  IN subordinates_to_be_added INT[],
  IN managers_to_be_removed INT[],
  IN subordinates_to_be_removed INT[],
  IN company_id_param INT,
  IN exclude_user_id INT
)
RETURNS SETOF users
LANGUAGE plpgsql
AS $$
DECLARE
  i INT;
  affected_row users%rowtype;
BEGIN

  -- Check if the number of managers to be added == subordinates to be added
  IF array_length(managers_to_be_added, 1) <> array_length(subordinates_to_be_added, 1) THEN
    RAISE EXCEPTION 'Number of user IDs and user roles must be equal';
  END IF;
  -- Check if the number of managers to be removed == subordinates to be removed
  IF array_length(managers_to_be_removed, 1) <> array_length(subordinates_to_be_removed, 1) THEN
    RAISE EXCEPTION 'Number of user IDs and user roles must be equal';
  END IF;

-- If statement to remove subordinates
    IF array_length(managers_to_be_removed, 1) > 0 AND array_length(subordinates_to_be_removed, 1) > 0 THEN
      FOR i IN 1..array_length(managers_to_be_removed, 1) LOOP

        -- check if the manager id or subordinate id is = to my id
        IF managers_to_be_removed[i] = exclude_user_id THEN
          RAISE EXCEPTION 'Can not remove your own subordinate: %', subordinates_to_be_removed[i];
        END IF;

        -- Check manager role
        IF NOT EXISTS (
            SELECT user_role
            FROM users
            WHERE id = managers_to_be_removed[i]
                AND company_id = company_id_param
                AND user_role = 'manager'
        )
        THEN
            RAISE EXCEPTION 'Manager not found.';
        END IF;

        -- Check subordinate role
        IF NOT EXISTS (
            SELECT user_role
            FROM users
            WHERE id = subordinates_to_be_removed[i]
                AND company_id = company_id_param
                AND user_role != 'manager'
        )
        THEN
            RAISE EXCEPTION 'Subordinate not found.';
        END IF;

        IF (SELECT user_role FROM users WHERE id = subordinates_to_be_removed[i] AND company_id = company_id_param) = 'manager' OR NULL THEN
          RAISE EXCEPTION 'The user with ID % cannot be a manager.', subordinates_to_be_removed[i];
        END IF;

        -- Delete from Hierarchies table
        DELETE FROM Hierarchies
        WHERE manager_id = managers_to_be_removed[i] AND subordinate_id = subordinates_to_be_removed[i];
      END LOOP;
    END IF;



    -- If statement to add subordinates
    IF array_length(managers_to_be_added, 1) > 0 AND array_length(subordinates_to_be_added, 1) > 0 THEN
      FOR i IN 1..array_length(subordinates_to_be_added, 1) LOOP

        -- check if the manager id or subordinate id is = to my id
        IF managers_to_be_added[i] = exclude_user_id THEN
          RAISE EXCEPTION 'Can not add your own subordinate';
        END IF;

       -- Check manager role
        IF NOT EXISTS (
            SELECT user_role
            FROM users
            WHERE id = managers_to_be_added[i]
                AND company_id = company_id_param
                AND user_role = 'manager'
        )
        THEN
           RAISE EXCEPTION 'Manager not found.';
        END IF;

        -- Check subordinate role
        IF NOT EXISTS (
            SELECT user_role
            FROM users
            WHERE id = subordinates_to_be_added[i]
                AND company_id = company_id_param
                AND user_role != 'manager'
        )
        THEN
            RAISE EXCEPTION 'Subordinate not found.';
        END IF;

        -- Insert into Hierarchies table
        INSERT INTO Hierarchies (manager_id, subordinate_id)
        VALUES (managers_to_be_added[i], subordinates_to_be_added[i]);
      END LOOP;
    END IF;

  -- Return the affected rows
  RETURN QUERY SELECT * FROM users WHERE id = ANY(user_ids) AND company_id = company_id_param;

END $$;
