# User Table

CREATE TABLE users( user_id INT PRIMARY KEY AUTO_INCREMENT,
					name VARCHAR(100) NOT NULL,
                    email VARCHAR(100) NOT NULL UNIQUE,
                    password_hash VARCHAR(255) NOT NULL,
                    roles ENUM('user','admin') NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
                    
# Category Table

CREATE TABLE category( category_id INT PRIMARY KEY AUTO_INCREMENT,
						category_name VARCHAR(100) NOT NULL UNIQUE,
                        description VARCHAR(500));
                        
# Complaints Table

CREATE TABLE complaints(complaint_id INT Primary KEY AUTO_INCREMENT,
						user_id INT NOT NULL,
                        category_id INT NOT NULL,
                        description VARCHAR(500) NOT NULL,
                        complain_status ENUM('Open', 'In Progress', 'Resolved', 'Closed') NOT NULL DEFAULT 'Open',
						priority ENUM('Low', 'Medium', 'High') NOT NULL DEFAULT 'Medium',
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        FOREIGN KEY (user_id) REFERENCES users(user_id),
                        FOREIGN KEY (category_id) REFERENCES category(category_id));
                        
# Admin Replies Table

CREATE TABLE admin_replies( reply_id INT PRIMARY KEY AUTO_INCREMENT,
							complaint_id INT NOT NULL,
                            admin_id INT NOT NULL,
                            reply_text TEXT NOT NULL,
                            reply_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                            FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id),
                            FOREIGN KEY (admin_id) REFERENCES users(user_id));
                            
# Complaint status log table

CREATE TABLE complaint_status_log( log_id INT PRIMARY KEY AUTO_INCREMENT,
									complaint_id INT NOT NULL,
                                    complaint_status ENUM('Open', 'In Progress', 'Resolved', 'Closed') NOT NULL,
                                    changed_by_user_id INT NOT NULL,
                                    complaint_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id),
                                    FOREIGN KEY (changed_by_user_id) REFERENCES users(user_id));
                                    
# User Login Activity Table

CREATE TABLE user_login_activity(login_id INT PRIMARY KEY AUTO_INCREMENT,
								 user_id INT NOT NULL,
                                 login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 ip_address VARCHAR(45) NOT NULL,
                                 FOREIGN KEY (user_id) REFERENCES users(user_id));
                                 
# Complaint Attachment Table

CREATE TABLE complaint_attachment( attachment_id INT PRIMARY KEY AUTO_INCREMENT,
									complaint_id INT NOT NULL,
                                    file_name VARCHAR(255) NOT NULL,
                                    file_type VARCHAR(30) NOT NULL,
                                    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                    FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id));
                                    
# Status Enum Table

CREATE TABLE status_enum (status_value VARCHAR(20) PRIMARY KEY);

#Inserting values in status_enum table

INSERT INTO status_enum VALUES ('Open'), ('In Progress'), ('Resolved'), ('Closed');
