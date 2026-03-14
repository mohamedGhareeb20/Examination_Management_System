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

    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
);

------------------------------------------------------

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
CREATE TABLE StudentExam(
    StudentExamID INT IDENTITY PRIMARY KEY,
    StudentID INT,
    ExamID INT,
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
