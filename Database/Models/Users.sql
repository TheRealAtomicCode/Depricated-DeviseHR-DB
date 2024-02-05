CREATE TABLE Users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(20) NOT NULL,
  last_name VARCHAR(20) NOT NULL,
  title VARCHAR(20),
  email VARCHAR(60) NOT NULL UNIQUE,
  password_hash VARCHAR(60),
  date_of_birth DATE,
  annual_leave_start_date DATE NOT NULL,
  profile_picture TEXT,
  is_terminated BOOLEAN NOT NULL DEFAULT false,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  refresh_tokens TEXT[] DEFAULT ARRAY[]::TEXT[] NOT NULL,
  ni_no VARCHAR(60),
  drivers_licence_number VARCHAR(60),
  drivers_licence_expiration_date DATE,
  passport_number VARCHAR(60),
  passport_expiration_date DATE,
  enable_reminders BOOLEAN NOT NULL DEFAULT false,
  enable_birthday_reminder BOOLEAN NOT NULL DEFAULT false,
  enable_receive_requests BOOLEAN NOT NULL DEFAULT false,
  enable_receive_requests_from_my_department BOOLEAN NOT NULL DEFAULT false,
  contracted_leave_start_date DATE,
  added_by_operator INT NOT NULL,
  added_by_user INT NOT NULL,
  updated_by_operator INT,
  updated_by_user INT,
  verification_code VARCHAR(10),
  login_attempt SMALLINT DEFAULT 0, 
  last_login_time TIMESTAMP,
  last_active_time TIMESTAMP,
  user_type INT NOT NULL,
  company_id INTEGER NOT NULL,
  role_id INTEGER,
  FOREIGN KEY (company_id) REFERENCES Companies (id),
  FOREIGN KEY (role_id) REFERENCES Roles (id),
 
  CONSTRAINT check_user_type CHECK (user_type IN (1, 2, 3))
);