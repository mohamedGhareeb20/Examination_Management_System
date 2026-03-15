-------------------------------------------
-- Table: Branch
-------------------------------------------
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
    FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
);
------------------------------------------------------
-- Table: Course
------------------------------------------------------
CREATE TABLE Course(
    CourseID INT IDENTITY PRIMARY KEY,
    CourseName NVARCHAR(100),
    TrackID INT,
    MinDegree INT,
    MaxDegree INT,
    FOREIGN KEY (TrackID) REFERENCES Track(TrackID)
);
------------------------------------------------------
-- Table: Instructor
------------------------------------------------------
CREATE TABLE Instructor(
    InstructorID INT IDENTITY PRIMARY KEY,
    InstructorName NVARCHAR(100),
    Email NVARCHAR(100),
    DepartmentNo INT
);
------------------------------------------------------
-- Table: Instructor_Course
------------------------------------------------------
CREATE TABLE Instructor_Course(
    InstructorID INT,
    CourseID INT,
    PRIMARY KEY (InstructorID, CourseID),
    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
------------------------------------------------------
-- Table: Student
------------------------------------------------------
CREATE TABLE Student(
    StudentID INT IDENTITY PRIMARY KEY,
    StudentName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20)
);
------------------------------------------------------
-- Table: Student_Track
------------------------------------------------------
CREATE TABLE Student_Track(
    StudentID INT,
    TrackID INT,
    PRIMARY KEY (StudentID, TrackID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (TrackID) REFERENCES Track(TrackID)
);
------------------------------------------------------
-- Table: Question
------------------------------------------------------
CREATE TABLE Question(
    QuestionID INT IDENTITY PRIMARY KEY,
    CourseID INT,
    QuestionText NVARCHAR(MAX),
    QuestionType NVARCHAR(10),   -- MCQ or TF
    Points INT,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
------------------------------------------------------
-- Table:QuestionOption
------------------------------------------------------
CREATE TABLE QuestionOption(
    OptionID INT IDENTITY PRIMARY KEY,
    QuestionID INT,
    OptionText NVARCHAR(MAX),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
);
------------------------------------------------------
-- Table: ModelAnswer
------------------------------------------------------
CREATE TABLE ModelAnswer(
    ModelAnswerID INT IDENTITY PRIMARY KEY,
    QuestionID INT,
    OptionID INT,
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID),
    FOREIGN KEY (OptionID) REFERENCES QuestionOption(OptionID)
);
------------------------------------------------------
-- Table: Exam
------------------------------------------------------
CREATE TABLE Exam(
    ExamID INT IDENTITY PRIMARY KEY,
    ExamName NVARCHAR(100),
    CourseID INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    TotalQuestions INT,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);
------------------------------------------------------
-- Table: ExamQuestion
------------------------------------------------------
CREATE TABLE ExamQuestion(
    ExamID INT,
    QuestionID INT,
    OrderNo INT,
    PRIMARY KEY (ExamID, QuestionID),
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID),
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
    TotalGrade FLOAT,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID)
);
------------------------------------------------------
-- Table: StudentAnswer
------------------------------------------------------
CREATE TABLE StudentAnswer(
    StudentExamID INT,
    QuestionID INT,
    ChosenOptionID INT,
    PRIMARY KEY (StudentExamID, QuestionID),
    FOREIGN KEY (StudentExamID) REFERENCES StudentExam(StudentExamID),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID),
    FOREIGN KEY (ChosenOptionID) REFERENCES QuestionOption(OptionID)
    );
