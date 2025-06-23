
#Adding updated_by_user_id column in complaints table
ALTER TABLE complaints ADD updated_by_user_id INT;

ALTER TABLE complaints ADD CONSTRAINT fk_updated_by_user
FOREIGN KEY (updated_by_user_id) REFERENCES users(user_id);


# Triggers to log status changes or auto-update timestamps

DELIMITER $$
CREATE TRIGGER trg_log_complaint_status
BEFORE UPDATE ON complaints
FOR EACH ROW BEGIN
IF NEW.status_value <> OLD.status_value THEN
    INSERT INTO complaint_status_log (complaint_id, complaint_status, changed_by_user_id, complaint_timestamp)
    VALUES (NEW.complaint_id, NEW.status_value, NEW.updated_by_user_id, CURRENT_TIMESTAMP);
END IF;
END $$
DELIMITER ;

# Stored procedures for complaint submission

DELIMITER $$
CREATE PROCEDURE submit_complaint( IN p_user_id INT, IN p_category_id INT, IN p_description varchar(500), IN p_priority varchar(10))
BEGIN 
IF p_priority NOT IN ('Low', 'Medium', 'High') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid priority level';
ELSE
INSERT INTO complaints( user_id, category_id, description, status_value, priority, updated_by_user_id)
VALUES( p_user_id, p_category_id, p_description, 'Open', p_priority, p_user_id);
END IF;
END $$
DELIMITER ;

# Views such as user complaint view

CREATE VIEW user_complaints_view AS 
SELECT c.complaint_id, c.user_id, u.name AS user_name, c.category_id, cat.category_name, c.description, c.status_value, c.priority, c.created_at, c.last_updated
FROM complaints c JOin users u ON c.user_id = u.user_id JOIN category cat ON c.category_id = cat.category_id
WHERE c.is_deleted = false;

# Auto-flagging unresolved complaints using MYSQL Events

DELIMITER $$
CREATE EVENT escalate_old_complaints ON SCHEDULE EVERY 1 DAY
DO BEGIN UPDATE complaints
SET priority = 'High' Where status_value = 'Open' AND created_at < NOW() - INTERVAL 3 DAY;
END $$
DELIMITER ;

# Full-text search on complaint descriptions

ALTER TABLE complaints
ADD FULLTEXT INDEX idx_ft_description(description);

# Audit table to log all complaint updates with user and timestamp

CREATE TABLE complaint_audit_log(audit_id INT PRIMARY KEY AUTO_INCREMENT,
								 complaint_id INT NOT NULL,
                                 updated_by_user_id INT NOT NULL,
                                 field_changed VARCHAR(100),
                                 old_value TEXT,
                                 new_value TEXT,
                                 changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id),
                                 FOREIGN KEY (updated_by_user_id) REFERENCES users(user_id));
                                 
DELIMITER $$
CREATE TRIGGER trg_audit_complaint_changes
BEFORE UPDATE ON complaints
FOR EACH ROW
BEGIN
    IF NEW.description <> OLD.description THEN
        INSERT INTO complaint_audit_log (
            complaint_id,
            updated_by_user_id,
            field_changed,
            old_value,
            new_value,
            changed_at
        )
        VALUES (
            NEW.complaint_id,
            NEW.updated_by_user_id,
            'description',
            OLD.description,
            NEW.description,
            CURRENT_TIMESTAMP
        );
    END IF;
END $$
DELIMITER ;
