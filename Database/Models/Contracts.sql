CREATE TABLE Contracts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  pattern_id INTEGER,

  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  added_by INT NOT NULL,
  updated_by INT,
  
  contract_type INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,

  contracted_hours_per_week_in_minutes INTEGER NOT NULL DEFAULT 480, --contracted_working_hours_per_week_in_minutes
  company_hours_per_week_in_minutes INTEGER NOT NULL, -- full_time_working_hours_per_week_in_minutes
  contracted_days_per_week_in_halfs INTEGER DEFAULT 0 NOT NULL, --contracted_working_days_per_week
  company_days_per_week_in_halfs INTEGER DEFAULT 0 NOT NULL,
  average_working_day INTEGER NOT NULL DEFAULT 480,
  is_leave_in_days BOOLEAN NOT NULL DEFAULT true,
  company_leave_entitlement  INTEGER NOT NULL DEFAULT 0, -- companies_full_time_annual_leave_entitlement
  contracted_leave_entitlement INTEGER NOT NULL DEFAULT 0,
  this_contracts_leave_allowence INTEGER NOT NULL DEFAULT 0,
  term_time_id INTEGER,

  discarded_id INTEGER,
  discarded_xnumber INTEGER,

  -- check start day does noy == end day has been removed
  CONSTRAINT check_contracted_days_per_week_dont_exceed_14 CHECK (contracted_days_per_week_in_halfs >= 0 AND contracted_days_per_week_in_halfs <= 14), -- when calculating annual leave in hours
  CONSTRAINT check_company_days_per_week_dont_exceed_14 CHECK (company_days_per_week_in_halfs >= 0 AND company_days_per_week_in_halfs <= 14), -- when calculating annual leave in hours
  CONSTRAINT contracted_hours_per_week_in_minutes CHECK ((contracted_hours_per_week_in_minutes > 0 AND contracted_hours_per_week_in_minutes <= 10080) OR NULL),
  CONSTRAINT full_time_working_hours_per_week_limit CHECK (company_hours_per_week_in_minutes >= 0 AND company_hours_per_week_in_minutes <= 10080),
  CONSTRAINT contract_type_check CHECK (
    (contract_type = 3 AND pattern_id IS NOT NULL AND pattern_id > 0) OR
    (contract_type = 1 AND pattern_id IS NULL) OR
    (contract_type = 2 AND pattern_id IS NULL)
  ),
  CONSTRAINT avrage_working_day_limit CHECK (average_working_day >= 0 AND average_working_day <= 1440), -- when calculating annual leave in days
  CONSTRAINT company_leave_entitlement_limit CHECK (company_leave_entitlement >= 0),
  CONSTRAINT contracted_leave_entitlement_limit CHECK (contracted_leave_entitlement >= 0),
  CONSTRAINT this_contracts_leave_allowence_limit CHECK (this_contracts_leave_allowence >= 0),
  CONSTRAINT term_time_contracts_have_term_time_id CHECK (term_time_id >= 0),
  CONSTRAINT check_start_date_not_after_end_date CHECK (start_date <= end_date),

  FOREIGN KEY (user_id) REFERENCES Users (id),
  FOREIGN KEY (company_id) REFERENCES Companies (id),
  CONSTRAINT check_contract_type CHECK (contract_type IN (1, 2, 3))
);