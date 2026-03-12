-- Create the main database
CREATE DATABASE ITI_Exam_System;
GO

USE ITI_Exam_System;
GO

-- execute all the files in order
:r ".\src\01_Schema_and_Tables.sql"
:r ".\src\02_Security_Roles.sql"
:r ".\src\03_CRUD_Procedures.sql"
:r ".\src\04_Core_Exam_Logic.sql"
:r ".\src\05_Reports.sql"
:r ".\tests\06_Insert_Sample_Data.sql"

PRINT 'Database built successfully';