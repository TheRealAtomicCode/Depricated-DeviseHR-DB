CREATE OR REPLACE FUNCTION edit_user_roles(
  IN user_ids INT[],
  IN user_roles TEXT[],
  IN role_ids INT[],
  IN company_id_param INT,
  IN exclude_user_id INT
)
RETURNS SETOF users
LANGUAGE plpgsql
AS $$
DECLARE
  i INT;
  selected_user TEXT;
  affected_row users%rowtype;
BEGIN
  -- Start the transaction

  -- Check if the number of user IDs and user roles is equal
  IF array_length(user_ids, 1) <> array_length(user_roles, 1) THEN
    RAISE EXCEPTION 'Number of user IDs and user roles must be equal';
  END IF;

  -- Update user roles
  IF array_length(user_ids, 1) IS NOT NULL THEN
    FOR i IN 1..array_length(user_ids, 1) LOOP
      IF user_ids[i] != exclude_user_id THEN
        IF user_roles[i] = 'manager' THEN
          -- Use the corresponding role_id from the role_ids array
          UPDATE users
          SET user_role = 'manager',
              role_id = role_ids[i]
          WHERE id = user_ids[i]
            AND company_id = company_id_param
			AND EXISTS (
                            SELECT company_id, id
                            FROM Roles
                            WHERE id = role_ids[i] AND company_id = company_id_param
                        )
          RETURNING * INTO affected_row;

        ELSIF user_roles[i] = 'employee' OR user_roles[i] = 'admin' THEN
          -- For roles other than 'manager', keep the existing user_role value
          UPDATE users
          SET user_role = user_roles[i]::user_role_enum,
              role_id = null
          WHERE id = user_ids[i] AND company_id = company_id_param
          RETURNING * INTO affected_row;
          DELETE FROM Hierarchies
          WHERE manager_id = user_ids[i];

        ELSE
          RAISE EXCEPTION 'Cannot update your own role: %', user_roles[i];
        END IF;
      END IF;
    END LOOP;
  END IF;

  -- Return the affected rows
  RETURN QUERY SELECT * FROM users WHERE id = ANY(user_ids) AND company_id = company_id_param;

END $$;