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
