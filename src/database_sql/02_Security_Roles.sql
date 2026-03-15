-- 1. CREATE ROLES
--------------------------------------------------------------------------------------
CREATE ROLE Administrator;
CREATE ROLE Instructor;
CREATE ROLE StudentRole;
GO


-- 2. ADMINISTRATOR PERMISSIONS 
--------------------------------------------------------------------------------------
ALTER ROLE db_owner ADD MEMBER Administrator;
GO


-- 3. STUDENT PERMISSIONS 
--------------------------------------------------------------------------------------
ALTER ROLE db_datareader ADD MEMBER StudentRole;
GO

DENY SELECT ON ModelAnswer TO StudentRole;
GO


-- 4. INSTRUCTOR PERMISSIONS
--------------------------------------------------------------------------------------
-- Grant permissions on Question Bank
GRANT SELECT, INSERT, UPDATE, DELETE ON Question TO Instructor;
GRANT SELECT, INSERT, UPDATE, DELETE ON QuestionOption TO Instructor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ModelAnswer TO Instructor;

-- Grant permissions on Exams
GRANT SELECT, INSERT, UPDATE, DELETE ON Exam TO Instructor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ExamQuestion TO Instructor;

-- Instructors also need to read Courses and Tracks to assign exams properly
GRANT SELECT ON Course TO Instructor;
GRANT SELECT ON Track TO Instructor;
GRANT SELECT ON Branch TO Instructor;
GO
