CREATE TABLE Discarded_Contracts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  company_id INTEGER NOT NULL,
  discard_reason VARCHAR(255) NOT NULL,
  discard_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  discard_by INT NOT NULL,
  first_contract_start_date DATE NOT NULL,
  last_contract_end_date DATE NOT NULL,
  first_contract_id INTEGER NOT NULL,
  last_contract_id INTEGER NOT NULL
);