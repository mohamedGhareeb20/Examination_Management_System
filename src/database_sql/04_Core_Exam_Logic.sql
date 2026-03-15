USE ITI_Exam_System;
GO

--------------------------------------------------------------------------------------
-- 1. GENERATE EXAM PROCEDURE (REQ-09 - CRITICAL)
--------------------------------------------------------------------------------------
/* Purpose: Generates a random exam for a specific course 
   Action: Selects random questions and inserts into Exam/ExamQuestion 
   Rules: Raises error if not enough questions exist in the bank. */
CREATE OR ALTER PROCEDURE GenerateExam 
    @CourseID INT, 
    @ExamName NVARCHAR(150), 
    @NumMCQ INT, 
    @NumTF INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Check if enough questions exist BEFORE starting the transaction
        DECLARE @ActualMCQ INT, @ActualTF INT;
        SELECT @ActualMCQ = COUNT(*) FROM Question WHERE CourseID = @CourseID AND QuestionType = 'MCQ';
        SELECT @ActualTF = COUNT(*) FROM Question WHERE CourseID = @CourseID AND QuestionType = 'TF';

        IF (@ActualMCQ < @NumMCQ OR @ActualTF < @NumTF)
        BEGIN
            -- Using THROW perfectly satisfies the "Raise error" rule in REQ-09
            THROW 50001, 'Error: Not enough questions in the bank for this course.', 1; 
        END

        BEGIN TRANSACTION; -- Required by NFR-03

        -- Insert Exam Header
        INSERT INTO Exam (ExamName, CourseID, TotalQuestions)
        VALUES (@ExamName, @CourseID, (@NumMCQ + @NumTF));

        DECLARE @NewExamID INT = SCOPE_IDENTITY();

        -- Insert random MCQ questions
        INSERT INTO ExamQuestion (ExamID, QuestionID, OrderNo)
        SELECT TOP (@NumMCQ) @NewExamID, QuestionID, ROW_NUMBER() OVER (ORDER BY NEWID())
        FROM Question 
        WHERE CourseID = @CourseID AND QuestionType = 'MCQ'
        ORDER BY NEWID();

        -- Insert random TF questions (Starts numbering exactly where MCQ finished)
        INSERT INTO ExamQuestion (ExamID, QuestionID, OrderNo)
        SELECT TOP (@NumTF) @NewExamID, QuestionID, (@NumMCQ + ROW_NUMBER() OVER (ORDER BY NEWID()))
        FROM Question 
        WHERE CourseID = @CourseID AND QuestionType = 'TF'
        ORDER BY NEWID();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 
        THROW; 
    END CATCH
END;
GO

--------------------------------------------------------------------------------------
-- 2. SUBMIT EXAM ANSWERS PROCEDURE (REQ-10 - CRITICAL)
--------------------------------------------------------------------------------------
/* Purpose: Records student answers submitted via XML 
   XML Format: <Answers><Answer><QuestionID>1</QuestionID><ChosenOptionID>5</ChosenOptionID></Answer></Answers> */
CREATE OR ALTER PROCEDURE SubmitExamAnswers
    @StudentID INT, 
    @ExamID INT, 
    @StartTime DATETIME, 
    @EndTime DATETIME, 
    @Answers XML
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION; -- Required by NFR-03

        -- Create the Student Exam Record (TotalGrade starts at 0)
        INSERT INTO StudentExam (StudentID, ExamID, StartTime, EndTime, TotalGrade)
        VALUES (@StudentID, @ExamID, @StartTime, @EndTime, 0);

        DECLARE @SE_ID INT = SCOPE_IDENTITY();

        -- Parse the XML and Insert into StudentAnswer
        INSERT INTO StudentAnswer (StudentExamID, QuestionID, ChosenOptionID)
        SELECT @SE_ID, 
               T.Item.value('(QuestionID)[1]', 'INT'), 
               T.Item.value('(ChosenOptionID)[1]', 'INT')
        FROM @Answers.nodes('/Answers/Answer') AS T(Item);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 
        THROW;
    END CATCH
END;
GO

--------------------------------------------------------------------------------------
-- 3. CORRECT EXAM PROCEDURE (REQ-11 - CRITICAL)
--------------------------------------------------------------------------------------
/* Purpose: Calculates the total grade for a student 
   Logic: Compares ChosenOptionID with ModelAnswer.OptionID and updates StudentExam */
CREATE OR ALTER PROCEDURE CorrectExam 
    @StudentExamID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION; -- Required by NFR-03

        DECLARE @FinalGrade INT = 0;

        -- Calculate total points ONLY for correct answers
        SELECT @FinalGrade = SUM(Q.Points)
        FROM StudentAnswer SA
        JOIN Question Q ON SA.QuestionID = Q.QuestionID
        JOIN ModelAnswer MA ON Q.QuestionID = MA.QuestionID
        WHERE SA.StudentExamID = @StudentExamID 
          AND SA.ChosenOptionID = MA.OptionID;

        -- Update the Final Grade (ISNULL protects against all skipped/wrong answers)
        UPDATE StudentExam 
        SET TotalGrade = ISNULL(@FinalGrade, 0) 
        WHERE StudentExamID = @StudentExamID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; 
        THROW;
    END CATCH
END;
GO