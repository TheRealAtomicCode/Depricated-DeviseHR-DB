CREATE TABLE leave_year (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  added_by INT NOT NULL,
  updated_by INT,
  leave_year_start_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  total_leave_entitlement INTEGER NOT NULL DEFAULT 0,
  total_leave_allowance INTEGER NOT NULL DEFAULT 0,
  leave_year_year INTEGER GENERATED ALWAYS AS (EXTRACT(YEAR FROM leave_year_start_date)) STORED,
  CONSTRAINT unique_leave_year_per_year_per_user UNIQUE (leave_year_year, user_id)
);