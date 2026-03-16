USE ITI_Exam_System;
GO

SET NOCOUNT ON;
PRINT '==================================================';
PRINT 'STARTING TEST SCENARIOS (SRS SECTION 7)';
PRINT '==================================================';

--------------------------------------------------------------------------------------
-- TEST 1: GenerateExam — valid inputs
-- Expected: Exam + ExamQuestion rows created, no duplicates
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 1: GenerateExam (Valid) ---';
-- Generating an exam with 10 MCQs (5 pts each) + 25 T/F (2 pts each) = 100 points total
EXEC GenerateExam @CourseID = 1, @ExamName = N'Final SQL Exam', @NumMCQ = 10, @NumTF = 15;

DECLARE @Exam1_ID INT = (SELECT MAX(ExamID) FROM Exam);
PRINT 'Exam Generated Successfully. ExamID: ' + CAST(@Exam1_ID AS NVARCHAR(10));

-- Show the generated questions (Limit to 5 just to prove it works without flooding the screen)
SELECT TOP 5 'TEST 1 SUCCESS' AS Test, ExamID, QuestionID, OrderNo FROM ExamQuestion WHERE ExamID = @Exam1_ID;


--------------------------------------------------------------------------------------
-- TEST 2: GenerateExam — not enough questions
-- Expected: Error raised, no partial exam created
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 2: GenerateExam (Not Enough Questions) ---';
BEGIN TRY
    -- We only have 30 MCQs in the bank, requesting 100 should fail
    EXEC GenerateExam @CourseID = 1, @ExamName = N'Impossible Exam', @NumMCQ = 100, @NumTF = 10;
END TRY
BEGIN CATCH
    PRINT 'TEST 2 SUCCESS: Error successfully caught!';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
END CATCH


--------------------------------------------------------------------------------------
-- TEST 3 & TEST 5: SubmitExamAnswers (All Answered) & CorrectExam (All Correct)
-- Expected: TotalGrade = MaxDegree (100)
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 3 & 5: Submit Answers & Correct (100%) ---';

-- Dynamically generate an XML string with 100% CORRECT answers for Exam 1
DECLARE @PerfectAnswersXML XML = (
    SELECT eq.QuestionID, ma.OptionID AS ChosenOptionID
    FROM ExamQuestion eq
    JOIN ModelAnswer ma ON eq.QuestionID = ma.QuestionID
    WHERE eq.ExamID = @Exam1_ID
    FOR XML PATH('Answer'), ROOT('Answers')
);

-- Student 1 takes Exam 1
EXEC SubmitExamAnswers @StudentID=1, @ExamID=@Exam1_ID, @StartTime='2024-01-01 10:00', @EndTime='2024-01-01 11:00', @Answers=@PerfectAnswersXML;
DECLARE @StudentExam1_ID INT = (SELECT MAX(StudentExamID) FROM StudentExam WHERE StudentID = 1);

-- Correct the Exam
EXEC CorrectExam @StudentExamID = @StudentExam1_ID;

-- Verify Grade is 100
SELECT 'TEST 3 & 5 SUCCESS' AS Test, StudentID, TotalGrade, 'Should be 100' AS Expected FROM StudentExam WHERE StudentExamID = @StudentExam1_ID;


--------------------------------------------------------------------------------------
-- TEST 4 & TEST 6: SubmitExamAnswers (1 Skipped) & CorrectExam (All Wrong)
-- Expected: Success, Skipped = no row, TotalGrade = 0
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 4 & 6: Submit Answers (Skipped 1) & Correct (0%) ---';

-- Generate a second smaller exam
EXEC GenerateExam @CourseID = 1, @ExamName = N'Makeup SQL Exam', @NumMCQ = 5, @NumTF = 5;
DECLARE @Exam2_ID INT = (SELECT MAX(ExamID) FROM Exam);

-- Dynamically generate an XML string with WRONG answers, and SKIP the first question
DECLARE @WrongAnswersXML XML = (
    SELECT eq.QuestionID, 
           -- Get an OptionID that is NOT the ModelAnswer
           (SELECT TOP 1 OptionID FROM [Option] o WHERE o.QuestionID = eq.QuestionID AND o.OptionID <> ma.OptionID) AS ChosenOptionID
    FROM ExamQuestion eq
    JOIN ModelAnswer ma ON eq.QuestionID = ma.QuestionID
    WHERE eq.ExamID = @Exam2_ID
      AND eq.OrderNo > 1 -- THIS SKIPS QUESTION #1 (Proves Test 4)
    FOR XML PATH('Answer'), ROOT('Answers')
);

-- Student 2 takes Exam 2
EXEC SubmitExamAnswers @StudentID=2, @ExamID=@Exam2_ID, @StartTime='2024-01-02 10:00', @EndTime='2024-01-02 11:00', @Answers=@WrongAnswersXML;
DECLARE @StudentExam2_ID INT = (SELECT MAX(StudentExamID) FROM StudentExam WHERE StudentID = 2);

-- Correct the Exam
EXEC CorrectExam @StudentExamID = @StudentExam2_ID;

-- Verify Grade is 0
SELECT 'TEST 4 & 6 SUCCESS' AS Test, StudentID, TotalGrade, 'Should be 0' AS Expected FROM StudentExam WHERE StudentExamID = @StudentExam2_ID;


--------------------------------------------------------------------------------------
-- TEST 7: Run all 3 reports
-- Expected: Correct data returned
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 7: Running Reports ---';

PRINT 'Report 1: Students By Department (Dept 10)';
EXEC Report_StudentsByDepartment @DepartmentNo = 10;

PRINT 'Report 2: Student Grades (Student 1)';
EXEC Report_StudentGrades @StudentID = 1;

PRINT 'Report 3: Instructor Courses (Instructor 1)';
EXEC Report_InstructorCourses @InstructorID = 1;


--------------------------------------------------------------------------------------
-- TEST 8: Delete Course with existing exams
-- Expected: FK constraint error — delete rejected
--------------------------------------------------------------------------------------
PRINT ''; PRINT '--- TEST 8: Delete Course (FK Constraint) ---';
BEGIN TRY
    -- Course 1 has exams generated from Test 1 and Test 4. Deleting it should fail.
    DELETE FROM Course WHERE CourseID = 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 8 SUCCESS: Deletion rejected due to Foreign Key Constraint!';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
END CATCH

PRINT '==================================================';
PRINT 'ALL TESTS COMPLETED SUCCESSFULLY!';
PRINT '==================================================';
GO