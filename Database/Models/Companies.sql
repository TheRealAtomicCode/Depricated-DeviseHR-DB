CREATE TABLE Companies (
  id SERIAL PRIMARY KEY,
  name VARCHAR(60) NOT NULL,
  licence_number VARCHAR(255) NOT NULL,
  account_number VARCHAR(6) NOT NULL UNIQUE,
  annual_leave_start_date DATE DEFAULT '1970-01-01',
  logo TEXT,
  enable_semi_personal_information BOOLEAN NOT NULL DEFAULT false,
  enable_show_employees BOOLEAN NOT NULL DEFAULT false,
  enable_toil BOOLEAN NOT NULL DEFAULT false,
  enable_overtime BOOLEAN NOT NULL DEFAULT false,
  enable_absence_conflicts_outside_departments BOOLEAN NOT NULL DEFAULT false,
  enable_carryover BOOLEAN NOT NULL DEFAULT false,
  enable_self_cancel_leave_requests BOOLEAN NOT NULL DEFAULT false,
  enable_edit_my_information BOOLEAN NOT NULL DEFAULT false,
  enable_accept_decline_shifts BOOLEAN NOT NULL DEFAULT false,
  enable_takeover_shift BOOLEAN NOT NULL DEFAULT false,
  enable_broadcast_shift_swap BOOLEAN NOT NULL DEFAULT false,
  enable_require_two_stage_approval BOOLEAN NOT NULL DEFAULT false,
  lang VARCHAR(5),
  country VARCHAR(5),
  main_contact_id INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_special_client BOOLEAN NOT NULL DEFAULT false,
  max_users_allowed INT NOT NULL,
  security_question_one VARCHAR(60),
  security_question_two VARCHAR(60),
  security_answer_two VARCHAR(60),
  expiration_date TIMESTAMP NOT NULL,
  phone_number VARCHAR(14) NOT NULL,
  added_by_operator INT NOT NULL,
  updated_by_operator INT
);
