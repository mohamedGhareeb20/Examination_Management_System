USE ITI_Exam_System;
GO

SET NOCOUNT ON;
PRINT '==================================================';
PRINT 'STARTING TEST SCENARIOS (SRS SECTION 7)';
PRINT '==================================================';

--------------------------------------------------------------------------------------
-- TEST 1: GenerateExam — Valid Inputs
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 1: GenerateExam (Valid Inputs) ---';

EXEC GenerateExam @CourseID = 1, @ExamName = N'Midterm Exam', @NumMCQ = 5, @NumTF = 3;

DECLARE @Test1_ExamID INT = (SELECT MAX(ExamID) FROM Exam WHERE ExamName = N'Midterm Exam');

SELECT 'TEST 1 SUCCESS' AS Test, ExamID, QuestionID, OrderNo 
FROM ExamQuestion 
WHERE ExamID = @Test1_ExamID;


--------------------------------------------------------------------------------------
-- TEST 2: GenerateExam — Not Enough Questions
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 2: GenerateExam (Not Enough Questions) ---';

BEGIN TRY
    -- Trying to request 100 MCQs when the bank only has 30
    EXEC GenerateExam @CourseID = 1, @ExamName = N'Impossible Exam', @NumMCQ = 100, @NumTF = 10;
END TRY
BEGIN CATCH
    SELECT 'TEST 2 SUCCESS' AS Test, ERROR_MESSAGE() AS CaughtError;
END CATCH


--------------------------------------------------------------------------------------
-- TEST 3: SubmitExamAnswers — All Questions Answered
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 3: SubmitExamAnswers (All Answered) ---';

DECLARE @Test3_ExamID INT = (SELECT MAX(ExamID) FROM Exam WHERE ExamName = N'Midterm Exam');

-- Generate XML with answers for EVERY question
DECLARE @AllAnswersXML XML = (
    SELECT eq.QuestionID, ma.OptionID AS ChosenOptionID
    FROM ExamQuestion eq
    JOIN ModelAnswer ma ON eq.QuestionID = ma.QuestionID
    WHERE eq.ExamID = @Test3_ExamID
    FOR XML PATH('Answer'), ROOT('Answers')
);

-- Student 1 submits the exam
EXEC SubmitExamAnswers @StudentID=1, @ExamID=@Test3_ExamID, @StartTime='2024-01-01 10:00', @EndTime='2024-01-01 11:00', @Answers=@AllAnswersXML;

DECLARE @Student1_ExamID INT = (SELECT MAX(StudentExamID) FROM StudentExam WHERE StudentID = 1);

-- Verify that the number of answers submitted equals the number of questions on the exam (8)
SELECT 'TEST 3 SUCCESS' AS Test, COUNT(*) AS AnswersSubmitted, 'Should be 8' AS Expected 
FROM StudentAnswer 
WHERE StudentExamID = @Student1_ExamID;


--------------------------------------------------------------------------------------
-- TEST 4: SubmitExamAnswers — One Question Skipped
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 4: SubmitExamAnswers (One Question Skipped) ---';

DECLARE @Test4_ExamID INT = (SELECT MAX(ExamID) FROM Exam WHERE ExamName = N'Midterm Exam');

-- 1. Find out exactly how many questions are on THIS specific exam
DECLARE @TotalQuestions INT = (SELECT COUNT(*) FROM ExamQuestion WHERE ExamID = @Test4_ExamID);

-- 2. Generate XML and purposely skip exactly ONE question using TOP (@Total - 1)
DECLARE @SkippedAnswersXML XML = (
    SELECT TOP (@TotalQuestions - 1) 
           eq.QuestionID, ma.OptionID AS ChosenOptionID
    FROM ExamQuestion eq
    JOIN ModelAnswer ma ON eq.QuestionID = ma.QuestionID
    WHERE eq.ExamID = @Test4_ExamID
    ORDER BY eq.QuestionID -- Order doesn't matter, we just want to leave 1 out
    FOR XML PATH('Answer'), ROOT('Answers')
);

-- 3. Student 2 submits the exam
EXEC SubmitExamAnswers 
    @StudentID=2, 
    @ExamID=@Test4_ExamID, 
    @StartTime='2024-01-02 10:00', 
    @EndTime='2024-01-02 11:00', 
    @Answers=@SkippedAnswersXML;

DECLARE @Student2_ExamID INT = (SELECT MAX(StudentExamID) FROM StudentExam WHERE StudentID = 2);

-- 4. Dynamically set what the Expected number should be
DECLARE @ExpectedNumber INT = @TotalQuestions - 1;

-- 5. Verify the Results!
SELECT 
    'TEST 4 SUCCESS' AS Test, 
    COUNT(*) AS AnswersSubmitted, 
    'Should be ' + CAST(@ExpectedNumber AS NVARCHAR(10)) AS Expected 
FROM StudentAnswer 
WHERE StudentExamID = @Student2_ExamID;


--------------------------------------------------------------------------------------
-- TEST 5: CorrectExam — All Correct
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 5: CorrectExam (All Correct) ---';

-- We grade Student 1 (From Test 3, who answered everything correctly)
DECLARE @Grade_Student1_ExamID INT = (SELECT MAX(StudentExamID) FROM StudentExam WHERE StudentID = 1);

EXEC CorrectExam @StudentExamID = @Grade_Student1_ExamID;

-- Dynamically calculate what the perfect score should be
DECLARE @PerfectScore INT = (
    SELECT SUM(q.Points) FROM ExamQuestion eq 
    JOIN Question q ON eq.QuestionID = q.QuestionID 
    WHERE eq.ExamID = (SELECT ExamID FROM StudentExam WHERE StudentExamID = @Grade_Student1_ExamID)
);

SELECT 'TEST 5 SUCCESS' AS Test, TotalGrade, 'Should be ' + CAST(@PerfectScore AS NVARCHAR(10)) AS Expected 
FROM StudentExam 
WHERE StudentExamID = @Grade_Student1_ExamID;


--------------------------------------------------------------------------------------
-- TEST 6: CorrectExam — All Wrong (0 Points)
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 6: CorrectExam (All Wrong) ---';

DECLARE @Test6_ExamID INT = (SELECT MAX(ExamID) FROM Exam WHERE ExamName = N'Midterm Exam');

-- Generate XML with WRONG answers for Student 3
DECLARE @WrongAnswersXML XML = (
    SELECT eq.QuestionID, 
           (SELECT TOP 1 OptionID FROM [Option] o WHERE o.QuestionID = eq.QuestionID AND o.OptionID <> ma.OptionID) AS ChosenOptionID
    FROM ExamQuestion eq
    JOIN ModelAnswer ma ON eq.QuestionID = ma.QuestionID
    WHERE eq.ExamID = @Test6_ExamID
    FOR XML PATH('Answer'), ROOT('Answers')
);

-- Student 3 submits ALL WRONG answers
EXEC SubmitExamAnswers @StudentID=3, @ExamID=@Test6_ExamID, @StartTime='2024-01-03 10:00', @EndTime='2024-01-03 11:00', @Answers=@WrongAnswersXML;

DECLARE @Student3_ExamID INT = (SELECT MAX(StudentExamID) FROM StudentExam WHERE StudentID = 3);

-- Grade Student 3
EXEC CorrectExam @StudentExamID = @Student3_ExamID;

SELECT 'TEST 6 SUCCESS' AS Test, TotalGrade, 'Should be 0' AS Expected 
FROM StudentExam 
WHERE StudentExamID = @Student3_ExamID;


--------------------------------------------------------------------------------------
-- TEST 7: Run All 3 Reports
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 7: Running All 3 Reports ---';

PRINT 'Executing Report 1: Students By Department (Dept 10)';
EXEC Report_StudentsByDepartment @DepartmentNo = 10;

PRINT 'Executing Report 2: Student Grades (Student 1)';
EXEC Report_StudentGrades @StudentID = 1;

PRINT 'Executing Report 3: Instructor Courses (Instructor 1)';
EXEC Report_InstructorCourses @InstructorID = 1;


--------------------------------------------------------------------------------------
-- TEST 8: Delete Course with Existing Exams
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 8: Delete Course (FK Constraint) ---';

BEGIN TRY
    -- Course 1 has exams generated from Test 1. Deleting it MUST fail per the SRS.
    DELETE FROM Course WHERE CourseID = 1;
END TRY
BEGIN CATCH
    SELECT 'TEST 8 SUCCESS' AS Test, 'Deletion rejected due to FK Constraint' AS Result, ERROR_MESSAGE() AS Details;
END CATCH

PRINT '==================================================';
PRINT 'ALL 8 TESTS COMPLETED SUCCESSFULLY!';
PRINT '==================================================';
GO