<<<<<<< HEAD
-- 1. Create Database safely
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ITI_Exam_System')
BEGIN
    CREATE DATABASE ITI_Exam_System;
END
GO

USE ITI_Exam_System;
GO

------------------------------------------------------
-- Table: Branch
------------------------------------------------------
CREATE TABLE Branch(
    BranchID INT IDENTITY PRIMARY KEY, 
    BranchName NVARCHAR(100) NOT NULL, 
    Location NVARCHAR(200)              
);

------------------------------------------------------
-- Table: Track
------------------------------------------------------
CREATE TABLE Track(
    TrackID INT IDENTITY PRIMARY KEY, 
    TrackName NVARCHAR(100),          
    BranchID INT,                     
    DurationMonths INT,               
    -- NFR-06: Explicit ON DELETE rule added
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID) ON DELETE CASCADE
);

------------------------------------------------------
-- Table: Course
------------------------------------------------------
CREATE TABLE Course(
    CourseID INT IDENTITY PRIMARY KEY, 
    CourseName NVARCHAR(100),          
    MinDegree INT,                     
    MaxDegree INT                     
);

------------------------------------------------------
-- Table: Track_Course (ADDED FROM SRS)
------------------------------------------------------
CREATE TABLE Track_Course(
    TrackID INT,
    CourseID INT,
    PRIMARY KEY (TrackID, CourseID),
    FOREIGN KEY (TrackID) REFERENCES Track(TrackID) ON DELETE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
);

------------------------------------------------------
-- Table: Instructor
------------------------------------------------------
CREATE TABLE Instructor(
    InstructorID INT IDENTITY PRIMARY KEY, 
    InstructorName NVARCHAR(100),          
    Email NVARCHAR(100) UNIQUE, -- SRS REQUIRES UNIQUE                 
    DepartmentNo INT                       
);

------------------------------------------------------
-- Table: Instructor_Course
------------------------------------------------------
CREATE TABLE Instructor_Course(
    InstructorID INT,
    CourseID INT,
    PRIMARY KEY (InstructorID, CourseID), 
    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID) ON DELETE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
);

------------------------------------------------------
-- Table: Student
------------------------------------------------------
CREATE TABLE Student(
    StudentID INT IDENTITY PRIMARY KEY, 
    StudentName NVARCHAR(100),          
    Email NVARCHAR(100) UNIQUE, -- SRS REQUIRES UNIQUE                
    Phone NVARCHAR(20)                  
);

------------------------------------------------------
-- Table: Student_Track
------------------------------------------------------
CREATE TABLE Student_Track(
    StudentID INT,
    TrackID INT,
    PRIMARY KEY (StudentID, TrackID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (TrackID) REFERENCES Track(TrackID) ON DELETE CASCADE
);

------------------------------------------------------
-- Table: Question
------------------------------------------------------
CREATE TABLE Question(
    QuestionID INT IDENTITY PRIMARY KEY, 
    CourseID INT,                        
    QuestionText NVARCHAR(MAX),          
    QuestionType NVARCHAR(10) CHECK (QuestionType IN ('MCQ','TF')), -- SRS REQUIRED CHECK
    Points INT,                          
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
);

------------------------------------------------------
-- Table: Option (RENAMED TO MATCH SRS)
------------------------------------------------------
-- Note: 'Option' is a reserved SQL word, so we put it in [Brackets]
CREATE TABLE [Option](
    OptionID INT IDENTITY PRIMARY KEY, 
    QuestionID INT,                    
    OptionText NVARCHAR(MAX),          
    OptionOrder INT, -- ADDED MISSING COLUMN FROM SRS                 
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID) ON DELETE CASCADE
);

------------------------------------------------------
-- Table: ModelAnswer
------------------------------------------------------
CREATE TABLE ModelAnswer(
    ModelAnswerID INT IDENTITY PRIMARY KEY,
    QuestionID INT UNIQUE, -- SRS REQUIRES UNIQUE (One answer per question)
    OptionID INT,       
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID),
    FOREIGN KEY (OptionID) REFERENCES [Option](OptionID)
);

------------------------------------------------------
-- Table: Exam
------------------------------------------------------
CREATE TABLE Exam(
    ExamID INT IDENTITY PRIMARY KEY,
    ExamName NVARCHAR(150),           
    CourseID INT,                     
    CreatedDate DATETIME DEFAULT GETDATE(), 
    TotalQuestions INT,               
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE CASCADE
);

------------------------------------------------------
-- Table: ExamQuestion
------------------------------------------------------
CREATE TABLE ExamQuestion(
    ExamID INT,
    QuestionID INT,
    OrderNo INT, 
    PRIMARY KEY (ExamID, QuestionID),
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID) ON DELETE CASCADE,
=======
-- Create Database & 14 Tables.
-- Don't forget the Primary Keys and Foreign Keys.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Table: Branch
-- Stores the different branches of the institute
CREATE TABLE Branch(
    BranchID INT IDENTITY PRIMARY KEY, -- Auto increment primary key
    BranchName NVARCHAR(100) NOT NULL, -- Name of the branch
    Location NVARCHAR(200)              -- Branch location
);

------------------------------------------------------

-- Table: Track
-- Each track belongs to a specific branch
CREATE TABLE Track(
    TrackID INT IDENTITY PRIMARY KEY, -- Unique ID for each track
    TrackName NVARCHAR(100),          -- Track name (Testing, AI, etc.)
    BranchID INT,                     -- Foreign key referencing Branch
    DurationMonths INT,               -- Track duration in months

    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);

------------------------------------------------------

-- Table: Course
-- Courses belong to tracks
CREATE TABLE Course(
    CourseID INT IDENTITY PRIMARY KEY, -- Unique course ID
    CourseName NVARCHAR(100),          -- Course name
    TrackID INT,                       -- Track that owns this course
    MinDegree INT,                     -- Minimum passing grade
    MaxDegree INT,                     -- Maximum grade

    FOREIGN KEY (TrackID) REFERENCES Track(TrackID)
);

------------------------------------------------------

-- Table: Instructor
-- Stores instructor information
CREATE TABLE Instructor(
    InstructorID INT IDENTITY PRIMARY KEY, -- Instructor ID
    InstructorName NVARCHAR(100),          -- Instructor name
    Email NVARCHAR(100),                   -- Instructor email
    DepartmentNo INT                       -- Department number
);

------------------------------------------------------

-- Table: Instructor_Course
-- Many-to-Many relationship between Instructor and Course
CREATE TABLE Instructor_Course(
    InstructorID INT,
    CourseID INT,

    PRIMARY KEY (InstructorID, CourseID), -- Composite key

    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

------------------------------------------------------

-- Table: Student
-- Stores student data
CREATE TABLE Student(
    StudentID INT IDENTITY PRIMARY KEY, -- Student ID
    StudentName NVARCHAR(100),          -- Student name
    Email NVARCHAR(100),                -- Student email
    Phone NVARCHAR(20)                  -- Phone number
);

------------------------------------------------------

-- Table: Student_Track
-- Many-to-Many relationship between students and tracks
CREATE TABLE Student_Track(
    StudentID INT,
    TrackID INT,

    PRIMARY KEY (StudentID, TrackID),

    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (TrackID) REFERENCES Track(TrackID)
);

------------------------------------------------------

-- Table: Question
-- Stores exam questions
CREATE TABLE Question(
    QuestionID INT IDENTITY PRIMARY KEY, -- Question ID
    CourseID INT,                        -- Course the question belongs to
    QuestionText NVARCHAR(MAX),          -- Question content
    QuestionType NVARCHAR(10),           -- MCQ or TF
    Points INT,                          -- Points for the question

    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

------------------------------------------------------

-- Table: QuestionOption
-- Stores possible answers for questions
CREATE TABLE QuestionOption(
    OptionID INT IDENTITY PRIMARY KEY, -- Option ID
    QuestionID INT,                    -- Question reference
    OptionText NVARCHAR(MAX),          -- Answer text

>>>>>>> 65058071a45543d0d15ba6428798aa82b0e77400
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
);

------------------------------------------------------
<<<<<<< HEAD
-- Table: StudentExam
------------------------------------------------------
=======

-- Table: ModelAnswer
-- Stores the correct answer for each question
CREATE TABLE ModelAnswer(
    ModelAnswerID INT IDENTITY PRIMARY KEY,
    QuestionID INT,     -- Question reference
    OptionID INT,       -- Correct option

    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID),
    FOREIGN KEY (OptionID) REFERENCES QuestionOption(OptionID)
);

------------------------------------------------------

-- Table: Exam
-- Stores exam information
CREATE TABLE Exam(
    ExamID INT IDENTITY PRIMARY KEY,
    ExamName NVARCHAR(100),           -- Name of the exam
    CourseID INT,                     -- Course of the exam
    CreatedDate DATETIME DEFAULT GETDATE(), -- Exam creation date
    TotalQuestions INT,               -- Total number of questions

    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

------------------------------------------------------

-- Table: ExamQuestion
-- Links questions to exams
CREATE TABLE ExamQuestion(
    ExamID INT,
    QuestionID INT,
    OrderNo INT, -- Order of the question inside the exam

    PRIMARY KEY (ExamID, QuestionID),

    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
);

------------------------------------------------------

-- Table: StudentExam
-- Represents a student's attempt at an exam
>>>>>>> 65058071a45543d0d15ba6428798aa82b0e77400
CREATE TABLE StudentExam(
    StudentExamID INT IDENTITY PRIMARY KEY,
    StudentID INT,
    ExamID INT,
<<<<<<< HEAD
    StartTime DATETIME, 
    EndTime DATETIME,   
    TotalGrade INT,   -- CHANGED FROM FLOAT TO INT PER SRS
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE,
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID) 
);

------------------------------------------------------
-- Table: StudentAnswer
------------------------------------------------------
CREATE TABLE StudentAnswer(
    StudentAnswerID INT IDENTITY PRIMARY KEY, -- FIXED PK TO MATCH SRS
    StudentExamID INT,
    QuestionID INT,
    ChosenOptionID INT, 
    FOREIGN KEY (StudentExamID) REFERENCES StudentExam(StudentExamID) ON DELETE CASCADE,
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID),
    FOREIGN KEY (ChosenOptionID) REFERENCES [Option](OptionID)
);
GO
=======
    StartTime DATETIME, -- When student started the exam
    EndTime DATETIME,   -- When student finished
    TotalGrade FLOAT,   -- Final grade

    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID)
);

------------------------------------------------------

-- Table: StudentAnswer
-- Stores student's answers
CREATE TABLE StudentAnswer(
    StudentExamID INT,
    QuestionID INT,
    ChosenOptionID INT, -- Option chosen by student

    PRIMARY KEY (StudentExamID, QuestionID),

    FOREIGN KEY (StudentExamID) REFERENCES StudentExam(StudentExamID),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID),
    FOREIGN KEY (ChosenOptionID) REFERENCES QuestionOption(OptionID)
);
>>>>>>> 65058071a45543d0d15ba6428798aa82b0e77400
