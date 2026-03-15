IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ITI_Exam_System')
BEGIN
    CREATE DATABASE ITI_Exam_System;
END
GO
USE ITI_Exam_System;
GO

-- execute all the files in order
:r "src\database_sql\01_Create_Tables.sql"
:r "src\database_sql\02_Security_Roles.sql"
:r "src\database_sql\03_CRUD_Procedures.sql"
:r "src\database_sql\04_Core_Exam_Logic.sql"
:r "src\database_sql\05_Reports.sql"
:r "tests\06_Sample_Data.sql"

PRINT 'Database built successfully';