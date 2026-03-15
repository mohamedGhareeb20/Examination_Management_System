USE ITI_Exam_System;
GO

-- 1. BRANCH PROCEDURES
--------------------------------------------------------------------------------------
/* Purpose: Inserts a new branch
   Inputs: @BranchName, @Location
   Outputs: None (Creates new record) */
CREATE OR ALTER PROCEDURE InsertBranch 
    @BranchName NVARCHAR(100), @Location NVARCHAR(200)
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Branch (BranchName, Location) VALUES (@BranchName, @Location);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Updates an existing branch
   Inputs: @BranchID, @BranchName, @Location
   Outputs: None (Updates record) */
CREATE OR ALTER PROCEDURE UpdateBranch 
    @BranchID INT, @BranchName NVARCHAR(100), @Location NVARCHAR(200)
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        UPDATE Branch SET BranchName = @BranchName, Location = @Location WHERE BranchID = @BranchID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Deletes a branch
   Inputs: @BranchID
   Outputs: None (Deletes record) */
CREATE OR ALTER PROCEDURE DeleteBranch @BranchID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM Branch WHERE BranchID = @BranchID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Retrieves all branches
   Inputs: None
   Outputs: Returns table of all branches */
CREATE OR ALTER PROCEDURE SelectBranch
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        SELECT * FROM Branch;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- 2. TRACK PROCEDURES
--------------------------------------------------------------------------------------
/* Purpose: Inserts a new track
   Inputs: @TrackName, @BranchID, @DurationMonths
   Outputs: None */
CREATE OR ALTER PROCEDURE InsertTrack 
    @TrackName NVARCHAR(100), @BranchID INT, @DurationMonths INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Track (TrackName, BranchID, DurationMonths) VALUES (@TrackName, @BranchID, @DurationMonths);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Updates an existing track
   Inputs: @TrackID, @TrackName, @BranchID, @DurationMonths
   Outputs: None */
CREATE OR ALTER PROCEDURE UpdateTrack 
    @TrackID INT, @TrackName NVARCHAR(100), @BranchID INT, @DurationMonths INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        UPDATE Track SET TrackName = @TrackName, BranchID = @BranchID, DurationMonths = @DurationMonths WHERE TrackID = @TrackID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Deletes a track
   Inputs: @TrackID
   Outputs: None */
CREATE OR ALTER PROCEDURE DeleteTrack @TrackID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM Track WHERE TrackID = @TrackID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Selects tracks belonging to a specific branch
   Inputs: @BranchID
   Outputs: Returns table of tracks */
CREATE OR ALTER PROCEDURE SelectByBranch @BranchID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        SELECT * FROM Track WHERE BranchID = @BranchID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- 3. COURSE PROCEDURES
--------------------------------------------------------------------------------------
/* Purpose: Inserts a new course
   Inputs: @CourseName, @MinDegree, @MaxDegree
   Outputs: None */
CREATE OR ALTER PROCEDURE InsertCourse 
    @CourseName NVARCHAR(100), @MinDegree INT, @MaxDegree INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Course (CourseName, MinDegree, MaxDegree) VALUES (@CourseName, @MinDegree, @MaxDegree);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Updates an existing course
   Inputs: @CourseID, @CourseName, @MinDegree, @MaxDegree
   Outputs: None */
CREATE OR ALTER PROCEDURE UpdateCourse 
    @CourseID INT, @CourseName NVARCHAR(100), @MinDegree INT, @MaxDegree INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        UPDATE Course SET CourseName = @CourseName, MinDegree = @MinDegree, MaxDegree = @MaxDegree WHERE CourseID = @CourseID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Deletes a course
   Inputs: @CourseID
   Outputs: None */
CREATE OR ALTER PROCEDURE DeleteCourse @CourseID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM Course WHERE CourseID = @CourseID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Retrieves all courses belonging to a specific track using the Junction table
   Inputs: @TrackID
   Outputs: Returns table of courses */
CREATE OR ALTER PROCEDURE SelectByTrack @TrackID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        SELECT c.* FROM Course c
        INNER JOIN Track_Course tc ON c.CourseID = tc.CourseID
        WHERE tc.TrackID = @TrackID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO


-- 4. INSTRUCTOR PROCEDURES
--------------------------------------------------------------------------------------
/* Purpose: Inserts an instructor
   Inputs: @InstructorName, @Email, @DepartmentNo
   Outputs: None */
CREATE OR ALTER PROCEDURE InsertInstructor 
    @InstructorName NVARCHAR(100), @Email NVARCHAR(100), @DepartmentNo INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Instructor (InstructorName, Email, DepartmentNo) VALUES (@InstructorName, @Email, @DepartmentNo);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Updates an instructor
   Inputs: @InstructorID, @InstructorName, @Email, @DepartmentNo
   Outputs: None */
CREATE OR ALTER PROCEDURE UpdateInstructor 
    @InstructorID INT, @InstructorName NVARCHAR(100), @Email NVARCHAR(100), @DepartmentNo INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        UPDATE Instructor SET InstructorName = @InstructorName, Email = @Email, DepartmentNo = @DepartmentNo WHERE InstructorID = @InstructorID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Assigns an instructor to a course (Many-to-Many junction)
   Inputs: @InstructorID, @CourseID
   Outputs: None */
CREATE OR ALTER PROCEDURE AssignInstructorToCourse 
    @InstructorID INT, @CourseID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Instructor_Course (InstructorID, CourseID) VALUES (@InstructorID, @CourseID);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO


-- 5. STUDENT PROCEDURES
--------------------------------------------------------------------------------------
/* Purpose: Inserts a student
   Inputs: @StudentName, @Email, @Phone
   Outputs: None */
CREATE OR ALTER PROCEDURE InsertStudent 
    @StudentName NVARCHAR(100), @Email NVARCHAR(100), @Phone NVARCHAR(20)
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Student (StudentName, Email, Phone) VALUES (@StudentName, @Email, @Phone);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Updates a student
   Inputs: @StudentID, @StudentName, @Email, @Phone
   Outputs: None */
CREATE OR ALTER PROCEDURE UpdateStudent 
    @StudentID INT, @StudentName NVARCHAR(100), @Email NVARCHAR(100), @Phone NVARCHAR(20)
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        UPDATE Student SET StudentName = @StudentName, Email = @Email, Phone = @Phone WHERE StudentID = @StudentID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Deletes a student
   Inputs: @StudentID
   Outputs: None */
CREATE OR ALTER PROCEDURE DeleteStudent @StudentID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM Student WHERE StudentID = @StudentID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Assigns a student to a track (Many-to-Many junction)
   Inputs: @StudentID, @TrackID
   Outputs: None */
CREATE OR ALTER PROCEDURE AssignStudentToTrack 
    @StudentID INT, @TrackID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Student_Track (StudentID, TrackID) VALUES (@StudentID, @TrackID);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO


-- 6. QUESTION & OPTION PROCEDURES (Bank Management)
--------------------------------------------------------------------------------------
/* Purpose: Inserts a new Question (MCQ or T/F)
   Inputs: @CourseID, @QuestionText, @QuestionType, @Points
   Outputs: None */
CREATE OR ALTER PROCEDURE InsertQuestion 
    @CourseID INT, @QuestionText NVARCHAR(MAX), @QuestionType NVARCHAR(10), @Points INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO Question (CourseID, QuestionText, QuestionType, Points) 
        VALUES (@CourseID, @QuestionText, @QuestionType, @Points);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Updates a Question
   Inputs: @QuestionID, @CourseID, @QuestionText, @QuestionType, @Points
   Outputs: None */
CREATE OR ALTER PROCEDURE UpdateQuestion 
    @QuestionID INT, @CourseID INT, @QuestionText NVARCHAR(MAX), @QuestionType NVARCHAR(10), @Points INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        UPDATE Question 
        SET CourseID = @CourseID, QuestionText = @QuestionText, QuestionType = @QuestionType, Points = @Points 
        WHERE QuestionID = @QuestionID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Deletes a Question
   Inputs: @QuestionID
   Outputs: None */
CREATE OR ALTER PROCEDURE DeleteQuestion @QuestionID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM Question WHERE QuestionID = @QuestionID;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Inserts options for questions (4 for MCQ, 2 for T/F)
   Inputs: @QuestionID, @OptionText, @OptionOrder
   Outputs: None */
CREATE OR ALTER PROCEDURE InsertOption 
    @QuestionID INT, @OptionText NVARCHAR(MAX), @OptionOrder INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QuestionID, @OptionText, @OptionOrder);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* Purpose: Sets the Model Answer for a question (Only 1 allowed)
   Inputs: @QuestionID, @OptionID
   Outputs: Upserts the ModelAnswer table */
CREATE OR ALTER PROCEDURE SetModelAnswer 
    @QuestionID INT, @OptionID INT
AS BEGIN
    BEGIN TRY
        BEGIN TRAN;
        -- Check if answer already exists to maintain UNIQUE rule
        IF EXISTS (SELECT 1 FROM ModelAnswer WHERE QuestionID = @QuestionID)
        BEGIN
            UPDATE ModelAnswer SET OptionID = @OptionID WHERE QuestionID = @QuestionID;
        END
        ELSE
        BEGIN
            INSERT INTO ModelAnswer (QuestionID, OptionID) VALUES (@QuestionID, @OptionID);
        END
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO