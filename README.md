# 🎓 Student Examination Management System (Database-Centric Design)

A professional, enterprise-level application developed for the **Information Technology Institute (ITI)**. This project implements a fully automated examination lifecycle where 100% of the business logic, data integrity rules, and grading calculations reside within **SQL Server Stored Procedures**.

---

## 📌 Project Architecture
This system follows a **Database-Centric Three-Tier Architecture**:
1.  **Data Layer:** SQL Server 2019+ storing a robust 15-table relational schema.
2.  **Logic Layer:** T-SQL Stored Procedures handling randomization, XML parsing, and ACID-compliant transactions.
3.  **Presentation Layer:** A Java Swing Desktop Application providing role-based portals for Administrators, Instructors, and Students.

---

## 🚀 Key Features by User Role

### 👑 Administrator Portal
*   **Infrastructure Management:** Full CRUD operations for Branches, Tracks, Courses, and Instructors.
*   **Enrollment Engine:** Functional logic to assign Students to Tracks and Instructors to Courses via junction table mapping.
*   **Administrative Reporting:** Real-time generation of student rosters filtered by Department (REQ-12).

### 👨‍🏫 Instructor Portal
*   **Automated Exam Generation:** Custom logic using `ORDER BY NEWID()` to produce unique exams from the question bank based on specific Course requirements (REQ-09).
*   **Question Bank Management:** Visualizing MCQ and True/False questions with weighted point systems.
*   **Workload Analytics:** Real-time report on student enrollment counts and class statistics (REQ-14).

### 🎓 Student Portal
*   **Examination Interface:** Dynamic fetching of exam questions and options from the SQL server.
*   **XML Submission:** Encapsulates student choices into a structured XML payload for high-performance database submission (REQ-10).
*   **Instant Grading:** Automatic correction engine that compares choices against Model Answers using secure SQL Transactions (REQ-11).
*   **Academic Transcript:** Full historical view of grades and percentages (REQ-13).

---

## 📂 Repository Structure
```text
├── docs/
│   ├── Database_ERD.png           # Visual Database Schema Design
│   ├── ITI_Exam_System_SRS_v3.pdf   # Technical Requirements Document
│   └── TestCases.xlsx             # QA Scenarios & Expected Results
├── src/
│   ├── database_sql/              # Core T-SQL Implementation
│   │   ├── 01_Create_Tables.sql   # DDL: Schema and 15 Tables
│   │   ├── 02_Security_Roles.sql  # DCL: RBAC Implementation
│   │   ├── 03_CRUD_Procedures.sql # Stored Procedures for Data Management
│   │   ├── 04_Core_Exam_Logic.sql  # Business Logic: Randomization & Grading
│   │   └── 05_Reports.sql         # SQL Reporting Procedures
│   └── desktop_app_java/          # Java GUI Presentation Layer
│       └── src/                   # Java Source Files (.java)
│           ├── mssql-jdbc-13.2.1.jre11.jar   # Microsoft JDBC Driver
│           └── mssql-jdbc_auth-13.2.1.x64.dll # Windows Auth Library
├── tests/
│   ├── 06_Sample_Data.sql         # High-volume mock data for system testing
│   └── 07_Test_Scenarios.sql      # Raw SQL execution tests for all 8 scenarios
├── 00_Run_All_Scripts.sql         # Master SQLCMD Build Script
└── README.md                      # Project Documentation
```
---
## ⚙️ Installation & Execution

### 1. Database Setup (SQL Server)

1. Open SQL Server Management Studio (SSMS).
2. Open the file `00_Run_All_Scripts.sql` from the root directory.
3. **Crucial:** Update the `:setvar path` line to match your local folder path (e.g., `D:\YourProjectFolder`).
4. Enable SQLCMD Mode *(Top Menu: Query > SQLCMD Mode)*.
5. Press **Execute (F5)** to build the entire system and load sample data.


### 2. Desktop Application (Java)

1. Open the `src/desktop_app_java` folder in **IntelliJ IDEA**.
2. Ensure the **Microsoft JDBC Driver** (`.jar`) is added as a library to the project.
3. Ensure the **Integrated Security DLL** is located in the `src` folder as shown in the structure.
4. Run `LoginScreen.java` to launch the application.
