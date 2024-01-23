CREATE TABLE Hierarchies (
    manager_id INTEGER,
    subordinate_id INTEGER,
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES Users (id),
    CONSTRAINT fk_subordinate FOREIGN KEY (subordinate_id) REFERENCES Users (id),
    CONSTRAINT pk_hierarchies PRIMARY KEY (manager_id, subordinate_id),
    CHECK (manager_id <> subordinate_id)
);