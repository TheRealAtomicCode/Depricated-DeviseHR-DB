
CREATE TABLE Working_Patterns (
  id SERIAL PRIMARY KEY,
  pattern_name VARCHAR(60) NOT NULL,
  company_id INTEGER NOT NULL CONSTRAINT fk_company REFERENCES Companies (id),

  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  added_by INT NOT NULL,
  updated_by INT,

  monday_start_time TIME,
  monday_end_time TIME,
  tuesday_start_time TIME,
  tuesday_end_time TIME,
  wednesday_start_time TIME,
  wednesday_end_time TIME,
  thursday_start_time TIME,
  thursday_end_time TIME,
  friday_start_time TIME,
  friday_end_time TIME,
  saturday_start_time TIME,
  saturday_end_time TIME,
  sunday_start_time TIME,
  sunday_end_time TIME,
	
  CONSTRAINT unique_pattern_name_per_company UNIQUE (company_id, pattern_name),
  CONSTRAINT check_monday_conflicts CHECK ((monday_start_time < monday_end_time OR monday_end_time < tuesday_start_time) AND monday_start_time != NULL AND monday_end_time != NULL),
  CONSTRAINT check_tuesday_conflicts CHECK ((tuesday_start_time < tuesday_end_time OR tuesday_end_time < wednesday_start_time) AND tuesday_end_time != NULL AND tuesday_end_time != NULL),
  CONSTRAINT check_wednesday_conflicts CHECK ((wednesday_start_time < wednesday_end_time OR wednesday_end_time < thursday_start_time) AND wednesday_end_time != NULL AND wednesday_end_time != NULL),
  CONSTRAINT check_thursday_conflicts CHECK ((thursday_start_time < thursday_end_time OR thursday_end_time < friday_start_time) AND thursday_end_time != NULL AND thursday_end_time != NULL),
  CONSTRAINT check_friday_conflicts CHECK ((friday_start_time < friday_end_time OR friday_end_time < saturday_start_time) AND friday_end_time != NULL AND friday_end_time != NULL),
  CONSTRAINT check_saturday_conflicts CHECK ((saturday_start_time < saturday_end_time OR saturday_end_time < sunday_start_time) AND saturday_end_time != NULL AND saturday_end_time != NULL),
  CONSTRAINT check_sunday_conflicts CHECK ((sunday_start_time < sunday_end_time OR sunday_end_time < monday_start_time) AND sunday_end_time != NULL AND sunday_end_time != NULL)
);