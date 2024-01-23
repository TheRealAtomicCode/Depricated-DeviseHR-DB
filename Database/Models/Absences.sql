CREATE TABLE Absences (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  contract_id INTEGER NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_first_half_day BOOLEAN,
  leave_is_in_days BOOLEAN NOT NULL DEFAULT true,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  days_deducted INTEGER,
  hours_deducted INTEGER,
  Absence_Types INTEGER NOT NULL CONSTRAINT fk_absence_type REFERENCES Absence_Types (id),
  comments VARCHAR(255),
  approved INT, -- CONSTRAINT fk_approved_by_manager REFERENCES Users (id),
  approved_by_admin INT, -- CONSTRAINT fk_approved_by_admin REFERENCES Users (id),

  added_by INT NOT NULL,   
  updated_by INT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT check_deduction_not_null CHECK (days_deducted IS NOT NULL OR hours_deducted IS NOT NULL),
  CONSTRAINT check_deducted_not_negative CHECK (days_deducted >= 0 OR hours_deducted >= 0),

  CONSTRAINT half_days_for_leaves_in_days CHECK (leave_is_in_days = true),
  CONSTRAINT check_start_date_not_after_end_date CHECK (start_date <= end_date),

  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES Users (id),
  CONSTRAINT fk_company FOREIGN KEY (company_id) REFERENCES Companies (id),
  CONSTRAINT fk_contract FOREIGN KEY (contract_id) REFERENCES Contracts (id)
);