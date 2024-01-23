CREATE TABLE Terms (
  id SERIAL PRIMARY KEY,
  company_id INTEGER,
  term_name VARCHAR(60),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  added_by INT NOT NULL,
  updated_by INT,

  start_date DATE NOT NULL,
  end_date DATE NOT NULL,

  CONSTRAINT check_start_date_not_after_end_date CHECK (start_date <= end_date),
  CONSTRAINT fk_company FOREIGN KEY (company_id) REFERENCES Companies (id),
  CONSTRAINT unique_term_name_per_company UNIQUE (company_id, term_name)
);