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
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
);

------------------------------------------------------
-- Table: StudentExam
------------------------------------------------------
CREATE TABLE StudentExam(
    StudentExamID INT IDENTITY PRIMARY KEY,
    StudentID INT,
    ExamID INT,
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