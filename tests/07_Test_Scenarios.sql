-----------------------
-----------------------
-- Test 1: GenerateExam - Valid Inputs
-----------------------
-----------------------
EXEC GenerateExam @CourseID = 1, @ExamName = 'SQL Midterm', @NumMCQ = 5, @NumTF = 3;

-- Check: Verify Exam exists and has exactly 8 questions
SELECT * FROM Exam WHERE ExamName = 'SQL Midterm';
SELECT * FROM Exam_Question WHERE ExamID = (SELECT MAX(ExamID) FROM Exam);
------------------------------
------------------------------
-- Test 2: GenerateExam - Not enough questions (Requesting 100 MCQ while we have 30)
------------------------------
------------------------------
BEGIN TRY
    EXEC GenerateExam @CourseID = 1, @ExamName = 'Impossible Exam', @NumMCQ = 200, @NumTF = 10;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorResult; -- Expected: 'Error: Not enough questions...'
END CATCH
------------------
------------------
-- Test 3: SubmitExamAnswers - Full Submission
------------------
------------------
DECLARE @AnswersXML XML = '
<Answers>
    <Answer><QuestionID>1</QuestionID><ChosenOptionID>1</ChosenOptionID></Answer>
    <Answer><QuestionID>2</QuestionID><ChosenOptionID>4</ChosenOptionID></Answer>
</Answers>';

EXEC SubmitExamAnswers @StudentID = 1, @ExamID = 1, 
                       @StartTime = '2026-03-16 10:00:00', 
                       @EndTime = '2026-03-16 11:00:00', 
                       @Answers = @AnswersXML;

-- Check: Verify student exam record and answers
SELECT * FROM StudentExam WHERE StudentID = 1 AND ExamID = 1;
SELECT * FROM StudentAnswer WHERE StudentExamID = (SELECT MAX(StudentExamID) FROM StudentExam);
--------------------
--------------------
-- Test 4: SubmitExamAnswers - Partial Submission (Skipping Question 2)
--------------------
--------------------
DECLARE @PartialXML XML = '
<Answers>
    <Answer><QuestionID>1</QuestionID><ChosenOptionID>1</ChosenOptionID></Answer>
</Answers>';

EXEC SubmitExamAnswers @StudentID = 2, @ExamID = 1, @StartTime = GETDATE(), @EndTime = GETDATE(), @Answers = @PartialXML;

-- Check: Only 1 row should exist for this StudentExamID in StudentAnswer table
----------------------------------
----------------------------------
-- Test 5: CorrectExam - Perfect Score
----------------------------------
----------------------------------
-- Note: In Sample Data, OptionOrder 1 was set as ModelAnswer
DECLARE @PerfectAnswers XML = (
    SELECT QuestionID, (SELECT OptionID FROM [Option] O WHERE O.QuestionID = Q.QuestionID AND OptionOrder = 1) as ChosenOptionID
    FROM Question Q WHERE CourseID = 1
    FOR XML PATH('Answer'), ROOT('Answers')
);
-- Submit and Correct
EXEC SubmitExamAnswers 3, 1, '2026-03-16', '2026-03-16', @PerfectAnswers;
DECLARE @SE_ID INT = SCOPE_IDENTITY();
EXEC CorrectExam @SE_ID;

-- Check: TotalGrade should match MaxDegree (100)
SELECT TotalGrade FROM StudentExam WHERE StudentExamID = @SE_ID;
----------------------------
----------------------------
-- Test 6: CorrectExam - Zero Score
----------------------------
----------------------------
-- Choosing OptionOrder 2 (which is wrong in our Sample Data logic)
DECLARE @WrongAnswers XML = '<Answers><Answer><QuestionID>1</QuestionID><ChosenOptionID>2</ChosenOptionID></Answer></Answers>';

EXEC SubmitExamAnswers 4, 1, GETDATE(), GETDATE(), @WrongAnswers;
DECLARE @SE_ID_Wrong INT = SCOPE_IDENTITY();
EXEC CorrectExam @SE_ID_Wrong;

-- Check: TotalGrade should be 0
SELECT TotalGrade FROM StudentExam WHERE StudentExamID = @SE_ID_Wrong;

-------------------------
-------------------------
-- Test 7: Reporting
-------------------------
-------------------------
PRINT 'Report 1: Students in Dept 10';
EXEC Report_StudentsByDepartment @DepartmentNo = 10;

PRINT 'Report 2: Grades for Student 1';
EXEC Report_StudentGrades @StudentID = 1;

PRINT 'Report 3: Courses for Instructor 1';
EXEC Report_InstructorCourses @InstructorID = 1;
--------------------------
--------------------------
-- Test 8: Integrity Check
--------------------------
--------------------------
-- Attempt to delete Course 1
DELETE FROM Course WHERE CourseID = 1;
-- Check: If CASCADE is active, Exam and Question rows for Course 1 should be GONE.
-- If NO ACTION was set, it would raise an error.
SELECT * FROM Exam WHERE CourseID = 1;
