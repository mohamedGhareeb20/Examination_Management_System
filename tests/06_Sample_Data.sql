USE ITI_Exam_System;
GO

SET NOCOUNT ON;
PRINT 'Starting Sample Data Insertion...';

--------------------------------------------------------------------------------------
-- 1. INSERT BRANCHES
--------------------------------------------------------------------------------------
INSERT INTO Branch (BranchName, Location) VALUES 
(N'Smart Village', N'Cairo-Alex Desert Road'),
(N'Mansoura', N'Mansoura University'),
(N'Alexandria', N'Borg El Arab');

--------------------------------------------------------------------------------------
-- 2. INSERT TRACKS
--------------------------------------------------------------------------------------
INSERT INTO Track (TrackName, BranchID, DurationMonths) VALUES 
(N'Software Development', 1, 9), (N'UI/UX Design', 1, 9),
(N'Data Science', 2, 9), (N'Artificial Intelligence', 2, 9),
(N'Cyber Security', 3, 9), (N'DevOps', 3, 9);

--------------------------------------------------------------------------------------
-- 3. INSERT COURSES
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
-- 5. INSERT INSTRUCTORS 
--------------------------------------------------------------------------------------
INSERT INTO Instructor (InstructorName, Email, DepartmentNo) VALUES 
(N'Ahmed Ali', N'ahmed@iti.eg', 10),
(N'Mona Hassan', N'mona@iti.eg', 10),
(N'Kareem Youssef', N'kareem@iti.eg', 20),
(N'Sara Ibrahim', N'sara@iti.eg', 30);

INSERT INTO Instructor_Course (InstructorID, CourseID) VALUES 
(1, 1), (1, 2), -- Ahmed teaches SQL, C++
(2, 3), (2, 4), -- Mona teaches Java, Web
(3, 1), (3, 5), -- Kareem teaches SQL, Python
(4, 2), (4, 6); -- Sara teaches C++, Security

--------------------------------------------------------------------------------------
-- 6. INSERT 20 REAL STUDENTS (For Java UI Login)
--------------------------------------------------------------------------------------
INSERT INTO Student (StudentName, Email, Phone) VALUES
('Radwa Mohamed','radwa@iti.eg','0101111111'), ('Sara Adel','sara@iti.eg','0102222222'),
('Omar Ibrahim','omar@iti.eg','0103333333'), ('Nour Ahmed','nour@iti.eg','0104444444'),
('Mai Ali','mai@iti.eg','0105555555'), ('Hiba Samir','hiba@iti.eg','0106666666'),
('Mostafa Yasser','mostafa@iti.eg','0107777777'), ('Yara Khaled','yara@iti.eg','0108888888'),
('Salma Osama','salma@iti.eg','0109999999'), ('Ali Tarek','ali@iti.eg','0111111111'),
('Mohamed Adel','mohamed@iti.eg','0112222222'), ('Mina George','mina@iti.eg','0113333333'),
('Laila Hassan','laila@iti.eg','0114444444'), ('Karim Mohamed','karim@iti.eg','0115555555'),
('Nada Ahmed','nada@iti.eg','0116666666'), ('Eman Ali','eman@iti.eg','0117777777'),
('Youssef Samy','youssef@iti.eg','0118888888'), ('Aya Fathy','aya@iti.eg','0119999999'),
('Seif Khaled','seif@iti.eg','0121111111'), ('Tasneem Emad','tasneem@iti.eg','0122222222');

-- Assign students evenly across the 6 tracks
INSERT INTO Student_Track (StudentID, TrackID) 
SELECT StudentID, ((StudentID % 6) + 1) FROM Student;

--------------------------------------------------------------------------------------
-- 7. GENERATE MULTIPLE QUESTION BANKS
--------------------------------------------------------------------------------------
DECLARE @i INT, @QID INT, @CorrectOptID INT;

-- ==============================================================
-- BANK 1: COURSE 1 (SQL Server) -> 30 MCQ, 20 T/F
-- ==============================================================
SET @i = 1;
WHILE @i <= 30 BEGIN
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points) 
    VALUES (1, N'SQL MCQ Question ' + CAST(@i AS NVARCHAR(10)), N'MCQ', 5);
    SET @QID = SCOPE_IDENTITY(); 
    
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Correct Option', 1);
    SET @CorrectOptID = SCOPE_IDENTITY(); 
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Wrong Option B', 2), (@QID, N'Wrong Option C', 3), (@QID, N'Wrong Option D', 4);
    
    INSERT INTO ModelAnswer (QuestionID, OptionID) VALUES (@QID, @CorrectOptID);
    SET @i = @i + 1;
END

SET @i = 1;
WHILE @i <= 20 BEGIN
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points) 
    VALUES (1, N'SQL T/F Question ' + CAST(@i AS NVARCHAR(10)), N'TF', 2);
    SET @QID = SCOPE_IDENTITY();
    
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'True', 1);
    SET @CorrectOptID = SCOPE_IDENTITY(); 
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'False', 2);
    
    INSERT INTO ModelAnswer (QuestionID, OptionID) VALUES (@QID, @CorrectOptID);
    SET @i = @i + 1;
END

-- ==============================================================
-- BANK 2: COURSE 2 (C++ Programming) -> 10 MCQ, 10 T/F
-- ==============================================================
SET @i = 1;
WHILE @i <= 10 BEGIN
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points) 
    VALUES (2, N'C++ MCQ Question ' + CAST(@i AS NVARCHAR(10)), N'MCQ', 10);
    SET @QID = SCOPE_IDENTITY(); 
    
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Correct Option', 1);
    SET @CorrectOptID = SCOPE_IDENTITY(); 
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'Wrong Option B', 2), (@QID, N'Wrong Option C', 3), (@QID, N'Wrong Option D', 4);
    
    INSERT INTO ModelAnswer (QuestionID, OptionID) VALUES (@QID, @CorrectOptID);
    SET @i = @i + 1;
END

SET @i = 1;
WHILE @i <= 10 BEGIN
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points) 
    VALUES (2, N'C++ T/F Question ' + CAST(@i AS NVARCHAR(10)), N'TF', 5);
    SET @QID = SCOPE_IDENTITY();
    
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'True', 1);
    SET @CorrectOptID = SCOPE_IDENTITY(); 
    INSERT INTO [Option] (QuestionID, OptionText, OptionOrder) VALUES (@QID, N'False', 2);
    
    INSERT INTO ModelAnswer (QuestionID, OptionID) VALUES (@QID, @CorrectOptID);
    SET @i = @i + 1;
END

PRINT 'Sample Data Successfully Inserted with Multiple Question Banks!';
GO