USE ITI_Exam_System;
GO

SET NOCOUNT ON;
PRINT 'Starting Sample Data Insertion...';

--------------------------------------------------------------------------------------
-- 1. INSERT BRANCHES (Req: 3+ Branches)
--------------------------------------------------------------------------------------
INSERT INTO Branch (BranchName, Location) VALUES 
(N'Smart Village', N'Cairo-Alex Desert Road'),
(N'Mansoura', N'Mansoura University'),
(N'Alexandria', N'Borg El Arab');

--------------------------------------------------------------------------------------
-- 2. INSERT TRACKS (Req: 2+ Tracks per Branch)
--------------------------------------------------------------------------------------
-- Branch 1 (Smart Village)
INSERT INTO Track (TrackName, BranchID, DurationMonths) VALUES (N'Software Development', 1, 9), (N'UI/UX Design', 1, 9);
-- Branch 2 (Mansoura)
INSERT INTO Track (TrackName, BranchID, DurationMonths) VALUES (N'Data Science', 2, 9), (N'Artificial Intelligence', 2, 9);
-- Branch 3 (Alexandria)
INSERT INTO Track (TrackName, BranchID, DurationMonths) VALUES (N'Cyber Security', 3, 9), (N'DevOps', 3, 9);

--------------------------------------------------------------------------------------
-- 3. INSERT COURSES (Req: 5+ Courses)
--------------------------------------------------------------------------------------
INSERT INTO Course (CourseName, MinDegree, MaxDegree) VALUES 
(N'SQL Server Database', 60, 100),
(N'C++ Programming', 60, 100),
(N'Java Fundamentals', 60, 100),
(N'Web Design (HTML/CSS)', 50, 100),
(N'Python for Data Science', 60, 100),
(N'Network Security', 60, 100);

--------------------------------------------------------------------------------------
-- 4. MAP TRACKS TO COURSES
--------------------------------------------------------------------------------------
INSERT INTO Track_Course (TrackID, CourseID) VALUES 
(1, 1), (1, 2), (1, 3), -- SD Track takes SQL, C++, Java
(3, 1), (3, 5),         -- Data Science takes SQL, Python
(5, 1), (5, 6);         -- CyberSec takes SQL, Security

--------------------------------------------------------------------------------------
-- 5. INSERT INSTRUCTORS (Req: 3+ Instructors assigned to 2+ courses)
--------------------------------------------------------------------------------------
INSERT INTO Instructor (InstructorName, Email, DepartmentNo) VALUES 
(N'Ahmed Ali', N'ahmed@iti.eg', 10),
(N'Mona Hassan', N'mona@iti.eg', 10),
(N'Kareem Youssef', N'kareem@iti.eg', 20),
(N'Sara Ibrahim', N'sara@iti.eg', 30);

-- Assign to 2+ courses each
INSERT INTO Instructor_Course (InstructorID, CourseID) VALUES 
(1, 1), (1, 2), -- Ahmed teaches SQL, C++
(2, 3), (2, 4), -- Mona teaches Java, Web
(3, 1), (3, 5), -- Kareem teaches SQL, Python
(4, 2), (4, 6); -- Sara teaches C++, Security

--------------------------------------------------------------------------------------
-- 6. INSERT STUDENTS (Req: 20+ Students across tracks)
--------------------------------------------------------------------------------------
DECLARE @i INT = 1;
DECLARE @StudentName NVARCHAR(100);
DECLARE @Email NVARCHAR(100);

-- Loop to quickly generate 20 students
WHILE @i <= 20
BEGIN
    SET @StudentName = N'Student ' + CAST(@i AS NVARCHAR(10));
    SET @Email = N'student' + CAST(@i AS NVARCHAR(10)) + N'@iti.eg';
    
    INSERT INTO Student (StudentName, Email, Phone) 
    VALUES (@StudentName, @Email, N'010000000' + CAST(@i AS NVARCHAR(2)));
    
    -- Assign students evenly across the 6 tracks
    INSERT INTO Student_Track (StudentID, TrackID) 
    VALUES (@i, ((@i % 6) + 1)); 

    SET @i = @i + 1;
END

--------------------------------------------------------------------------------------
-- 7. INSERT QUESTIONS, OPTIONS, AND MODEL ANSWERS 
-- (Req: 30+ MCQ, 20+ T/F - All with options & model answers)
--------------------------------------------------------------------------------------
DECLARE @QID INT, @CorrectOptID INT;
SET @i = 1;

-- A. GENERATE 30 MCQ QUESTIONS (Assigned to Course 1: SQL Server)
WHILE @i <= 30
BEGIN
    -- 1. Insert Question
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points) 
    VALUES (1, N'Sample MCQ Question ' + CAST(@i AS NVARCHAR(10)) + N' for SQL Server?', N'MCQ', 5);
    SET @QID = SCOPE_IDENTITY(); -- Get new QuestionID
    
    -- 2. Insert 4 Options
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Correct Option', 1);
    SET @CorrectOptID = SCOPE_IDENTITY(); -- Save the ID of the correct option
    
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Wrong Option B', 2);
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Wrong Option C', 3);
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Wrong Option D', 4);
    
    -- 3. Set Model Answer
    INSERT INTO ModelAnswer (QuestionID, OptionID) VALUES (@QID, @CorrectOptID);
    
    SET @i = @i + 1;
END

-- B. GENERATE 20 TRUE/FALSE QUESTIONS (Assigned to Course 1: SQL Server)
SET @i = 1;
WHILE @i <= 20
BEGIN
    -- 1. Insert Question
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points) 
    VALUES (1, N'Sample T/F Question ' + CAST(@i AS NVARCHAR(10)) + N' for SQL Server?', N'TF', 2);
    SET @QID = SCOPE_IDENTITY();
    
    -- 2. Insert 2 Options
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'True', 1);
    SET @CorrectOptID = SCOPE_IDENTITY(); -- Let's make 'True' the correct answer for all of them
    
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'False', 2);
    
    -- 3. Set Model Answer
    INSERT INTO ModelAnswer (QuestionID, OptionID) VALUES (@QID, @CorrectOptID);
    
    SET @i = @i + 1;
END

PRINT 'Sample Data Successfully Inserted!';
GO