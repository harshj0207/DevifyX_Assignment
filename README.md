
# Complaint Management Portal – MySQL Backend

## Overview

This project is a MySQL-based complaint management system designed to manage user complaints, categorize them, and allow admin responses. It supports tracking complaint statuses, managing escalation, and enabling secure and structured interaction with the database via views, triggers, procedures, and events.

## Schema Overview

The database is normalized and consists of the following key tables:

### 1. users
- Stores user data with roles (`user`, `admin`)
- Tracks account creation time
- Includes `is_deleted` flag

### 2. category
- Complaint categories with unique names and optional descriptions

### 3. complaints
- Core table for user complaints
- Includes status, priority, and timestamps
- Indexed on status, category, and user for query performance
- Contains `is_deleted` and `updated_by_user_id` fields

### 4. admin_replies
- Stores responses from admin with timestamps

### 5. complaint_status_log
- Audit log of complaint status changes
- Tracks user who changed the status and the time of change

### 6. user_login_activity
- Logs user logins and IP addresses

### 7. complaint_attachment
- Supports file uploads with type and timestamp

### 8. status_enum
- Enumerated complaint statuses to support future-proofing

### 9. complaint_audit_log
- General-purpose audit log for changes in complaint fields

## Advanced Features Implemented

1. **Triggers**  
   - `trg_log_complaint_status`: Automatically logs changes to complaint status in `complaint_status_log`.

2. **Stored Procedures**  
   - `submit_complaint`: Validates and inserts complaints while enforcing priority constraints.

3. **Views**  
   - `user_complaints_view`: Displays all user complaints with relevant joins and filters out deleted complaints.

4. **MySQL Events**  
   - `escalate_old_complaints`: Automatically escalates priority of open complaints older than 3 days.

5. **Full-text Search**  
   - Full-text index added on `description` field of `complaints` table for search optimization.

6. **Audit Logging**  
   - `complaint_audit_log` captures detailed changes to complaint fields, who changed them, and when.

## Assumptions Made

- Complaint escalation logic is purely time-based (older than 3 days).
- `status_enum` table is maintained for UI/backend sync, though ENUM is used in schema directly.
- Only authorized users (e.g., admins) will update complaint statuses.
- File uploads are handled by frontend/backend logic outside SQL scope.

## GPT Assistance Disclosure

GPT was used as a supplementary tool for:
- Reviewing and refining SQL queries for clarity and best practices
- Structuring documentation (e.g., this README)
