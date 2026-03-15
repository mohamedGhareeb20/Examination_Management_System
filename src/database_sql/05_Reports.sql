USE ITI_Exam_System;
GO

--------------------------------------------------------------------------------------
-- 1. REPORT: STUDENTS BY DEPARTMENT (REQ-12)
--------------------------------------------------------------------------------------
/* Purpose: Retrieves all students belonging to a specific department
   Inputs: @DepartmentNo
   Outputs: StudentID, Name, Email, Phone, TrackName, BranchName */
CREATE OR ALTER PROCEDURE Report_StudentsByDepartment
    @DepartmentNo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION; -- Required by NFR-03

        SELECT DISTINCT -- DISTINCT prevents duplicates if a student takes multiple courses in the same dept
            s.StudentID, 
            s.StudentName AS Name, -- Aliased to 'Name' to perfectly match SRS Output Columns
            s.Email, 
            s.Phone, 
            t.TrackName, 
            b.BranchName
        FROM Student s
        INNER JOIN Student_Track st ON s.StudentID = st.StudentID
        INNER JOIN Track t ON st.TrackID = t.TrackID
        INNER JOIN Branch b ON t.BranchID = b.BranchID
        -- Follow the path to find the Instructor's Department
        INNER JOIN Track_Course tc ON t.TrackID = tc.TrackID
        INNER JOIN Instructor_Course ic ON tc.CourseID = ic.CourseID
        INNER JOIN Instructor i ON ic.InstructorID = i.InstructorID
        WHERE i.DepartmentNo = @DepartmentNo; 

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW; -- THROW is cleaner and safer than RAISERROR in CATCH blocks
    END CATCH
END;
GO

--------------------------------------------------------------------------------------
-- 2. REPORT: STUDENT GRADES (REQ-13)
--------------------------------------------------------------------------------------
/* Purpose: Shows all exam results for a specific student
   Inputs: @StudentID
   Logic: Calculates Percentage = (TotalGrade / MaxDegree) * 100  */
CREATE OR ALTER PROCEDURE Report_StudentGrades
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION; -- Required by NFR-03

        SELECT 
            c.CourseName, 
            e.ExamName, 
            se.TotalGrade, 
            c.MaxDegree,
            -- NULLIF prevents a "Divide by Zero" error if MaxDegree is accidentally 0
            (CAST(se.TotalGrade AS FLOAT) / NULLIF(CAST(c.MaxDegree AS FLOAT), 0) * 100) AS [Percentage]
        FROM StudentExam se
        INNER JOIN Exam e ON se.ExamID = e.ExamID
        INNER JOIN Course c ON e.CourseID = c.CourseID
        WHERE se.StudentID = @StudentID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

--------------------------------------------------------------------------------------
-- 3. REPORT: INSTRUCTOR COURSES (REQ-14)
--------------------------------------------------------------------------------------
/* Purpose: Shows courses taught by an instructor and number of students enrolled
   Inputs: @InstructorID
   Outputs: CourseName, TrackName, StudentCount */
CREATE OR ALTER PROCEDURE Report_InstructorCourses
    @InstructorID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION; -- Required by NFR-03

        SELECT 
            c.CourseName, 
            t.TrackName,
            -- Your correlated subquery here is actually very smart!
            (SELECT COUNT(*) FROM Student_Track st WHERE st.TrackID = tc.TrackID) AS StudentCount
        FROM Instructor_Course ic
        INNER JOIN Course c ON ic.CourseID = c.CourseID
        INNER JOIN Track_Course tc ON c.CourseID = tc.CourseID
        INNER JOIN Track t ON tc.TrackID = t.TrackID
        WHERE ic.InstructorID = @InstructorID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO