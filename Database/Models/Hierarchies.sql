CREATE TABLE Hierarchies (
    id SERIAL PRIMARY KEY,
    manager_id INTEGER NOT NULL,
    subordinate_id INTEGER NOT NULL,
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES Users (id) ON DELETE CASCADE,
    CONSTRAINT fk_subordinate FOREIGN KEY (subordinate_id) REFERENCES Users (id) ON DELETE CASCADE,
    CONSTRAINT uq_hierarchies UNIQUE (manager_id, subordinate_id),
    CHECK (manager_id <> subordinate_id)
);



-- changed the cascade rules so that the hierarchy can get deleted when the role changes

-- CREATE TABLE Hierarchies (
--     id SERIAL PRIMARY KEY,
--     manager_id INTEGER NOT NULL,
--     subordinate_id INTEGER NOT NULL,
--     CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES Users (id),
--     CONSTRAINT fk_subordinate FOREIGN KEY (subordinate_id) REFERENCES Users (id),
--     CONSTRAINT uq_hierarchies UNIQUE (manager_id, subordinate_id),
--     CHECK (manager_id <> subordinate_id)
-- );

