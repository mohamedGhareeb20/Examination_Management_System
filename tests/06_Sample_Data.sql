-- To fill the database with fake data(Using INSERT INTO statements): 3 Branches, 20 Students, 50 Questions, etc., for testing.
--Sample Data
--3 Branches
INSERT INTO Branch (BranchName, Location)
VALUES
('Cairo', 'Nasr City'),
('Alexandria', 'Smouha'),
('Mansoura', 'Talkha');
--Tracks( 2 tarck for each branch)
INSERT INTO Track (TrackName, BranchID, DurationMonths)
VALUES
('Software Testing', 1, 6),
('Web Development', 1, 6),

('Business Intelligence', 2, 6),
('Data Analysis', 2, 6),

('AI', 3, 6),
('Mobile Development', 3, 6);
--Courses(5-6)
INSERT INTO Course (CourseName, TrackID, MinDegree, MaxDegree)
VALUES
('SQL Fundamentals', 1, 50, 100),
('Manual Testing', 1, 50, 100),
('Automation Testing', 1, 50, 100),

('HTML & CSS', 2, 50, 100),
('JavaScript Basics', 2, 50, 100),

('Python Programming', 4, 50, 100),
('Statistics 101', 4, 50, 100),

('Machine Learning', 5, 50, 100);
-- 3 Instructors with Assignments
INSERT INTO Instructor (InstructorName, Email, DepartmentNo)
VALUES
('Ahmed Hassan', 'ahmed@test.com', 10),
('Mona Ali', 'mona@test.com', 20),
('Youssef Saber', 'youssef@test.com', 30);

-- Each instructor teaches 2+ courses
INSERT INTO Instructor_Course (InstructorID, CourseID)
VALUES
(1, 1), (1, 2), (1, 3),
(2, 4), (2, 5),
(3, 6), (3, 7), (3, 8);
--20 students
INSERT INTO Student (StudentName, Email, Phone)
VALUES
('Radwa Mohamed','radwa01@mail.com','0101111111'),
('Sara Adel','sara02@mail.com','0102222222'),
('Omar Ibrahim','omar03@mail.com','0103333333'),
('Nour Ahmed','nour04@mail.com','0104444444'),
('Mai Ali','mai05@mail.com','0105555555'),
('Hiba Samir','hiba06@mail.com','0106666666'),
('Mostafa Yasser','mostafa07@mail.com','0107777777'),
('Yara Khaled','yara08@mail.com','0108888888'),
('Salma Osama','salma09@mail.com','0109999999'),
('Ali Tarek','ali10@mail.com','0111111111'),
('Mohamed Adel','mohamed11@mail.com','0112222222'),
('Mina George','mina12@mail.com','0113333333'),
('Laila Hassan','laila13@mail.com','0114444444'),
('Karim Mohamed','karim14@mail.com','0115555555'),
('Nada Ahmed','nada15@mail.com','0116666666'),
('Eman Ali','eman16@mail.com','0117777777'),
('Youssef Samy','youssef17@mail.com','0118888888'),
('Aya Fathy','aya18@mail.com','0119999999'),
('Seif Khaled','seif19@mail.com','0121111111'),
('Tasneem Emad','tasneem20@mail.com','0122222222');
--Assign Students to Tracks
INSERT INTO Student_Track(StudentID, TrackID)
VALUES
(1,1),(2,1),(3,1),(4,1),(5,1),
(6,2),(7,2),(8,2),(9,2),(10,2),
(11,3),(12,3),(13,3),(14,3),(15,3),
(16,4),(17,4),(18,4),(19,4),(20,4);
--30 MCQ (with options & model answers)
-- MCQ Questions for CourseID = 1 (SQL Fundamentals)
DECLARE @i INT = 1;

WHILE @i <= 30
BEGIN
    -- Insert question
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points)
    VALUES(1, CONCAT('MCQ Question ', @i, ' about SQL'), 'MCQ', 5);

    DECLARE @QID INT = SCOPE_IDENTITY();

    -- Options
    INSERT INTO QuestionOption(QuestionID, OptionText)
    VALUES (@QID, 'Option A'),
           (@QID, 'Option B'),
           (@QID, 'Option C'),
           (@QID, 'Option D');

    -- Model Answer (always Option A for simplicity)
    INSERT INTO ModelAnswer (QuestionID, OptionID)
    VALUES(@QID, (SELECT MIN(OptionID) FROM QuestionOption WHERE QuestionID = @QID));

    SET @i = @i + 1;
END;
-- 20 True/False Questions
-- True/False Questions for CourseID = 1
DECLARE @j INT = 1;

WHILE @j <= 20
BEGIN
    INSERT INTO Question (CourseID, QuestionText, QuestionType, Points)
    VALUES (1, CONCAT('TF Question ', @j, ' about SQL'), 'TF', 5);

    DECLARE @QID2 INT = SCOPE_IDENTITY();

    -- 2 options True/False
    INSERT INTO QuestionOption(QuestionID, OptionText)
    VALUES(@QID2, 'True'),
          (@QID2, 'False');

    -- ModelAnswer = Always the 2nd option (False) للتبسيط
    INSERT INTO ModelAnswer (QuestionID, OptionID)
    VALUES(@QID2, (SELECT MAX(OptionID) FROM QuestionOption WHERE QuestionID = @QID2));

    SET @j = @j + 1;
END;
