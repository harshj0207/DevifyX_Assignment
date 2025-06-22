#Adding updated_by_user_id column in complaints table
ALTER TABLE complaints ADD updated_by_user_id INT;
ALTER TABLE complaints ADD CONSTRAINT fk_updated_by_user
FOREIGN KEY (updated_by_user_id) REFERENCES users(user_id);


# Triggers to log status changes or auto-update timestamps

DELIMITER $$
CREATE TRIGGER trg_log_complaint_status
BEFORE UPDATE ON complaints
FOR EACH ROW BEGIN
IF NEW.complain_status <> OLD.complain_status THEN
    INSERT INTO complaint_status_log (complaint_id, complaint_status, changed_by_user_id, complaint_timestamp)
    VALUES (NEW.complaint_id, NEW.complain_status, NEW.updated_by_user_id, CURRENT_TIMESTAMP);
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
INSERT INTO complaints( user_id, category_id, description, priority)
VALUES( p_user_id, p_category_id, p_description, p_priority);
END IF;
END $$
DELIMITER ;

# Views such as user complaint view

CREATE VIEW user_complaints_view AS 
SELECT c.complaint_id, c.user_id, u.name AS user_name, c.category_id, cat.category_name, c.description, c.complain_status, c.priority, c.created_at, c.last_updated
FROM complaints c JOin users u ON c.user_id = u.user_id JOIN category cat ON c.category_id = cat.category_id
WHERE c.is_deleted = false;
